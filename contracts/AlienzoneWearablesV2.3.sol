// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Version: V2.3 — True quadratic bounded curve (x²)
// Changes from V2.2:
//   - Replaced hyperbolic curve 1/(S-x) with true quadratic bounded curve
//   - Formula: integral of P(t) = init + (ceil-init)×(t/S)² from supply to supply+amount
//   - Price naturally approaches ceilPriceFactor as supply → totalSupply
//   - All supplyFactor tokens are purchasable (token 20/20 included for Epic)
//   - Last token (20/20) costs ~4760 ZONE for Epic (integral from 19 to 20)
//   - curveFactor is IGNORED in price computation (kept in struct for ABI compatibility)
//   - getSpotPrice() added: returns marginal price P(supply) at current supply level
//
// Price formula (quadratic integral, safe 1e9 fixed-point to avoid overflow):
//   ns = supply × 1e9 / totalSupply
//   na = amount × 1e9 / totalSupply
//   sumTerms = 3×ns² + 3×ns×na + na²
//   cost = init×amount/1e18 + (ceil-init)×amount/1e18 × sumTerms / (3×1e18)

// Errors
    error InvalidFeePercent();
    error InvalidSignature();
    error InvalidOperator();
    error InsufficientBaseUnit();
    error AmountNotMultipleOfBaseUnit();
    error InvalidTotalSupply();
    error InvalidCurveFactor();
    error InvalidInitialPriceFactor();
    error InvalidCeilPriceFactor();
    error InvalidFloorPriceFactor();
    error WearableAlreadyCreated();
    error WearableNotCreated();
    error InvalidSaleState();
    error TotalSupplyExceeded();
    error InsufficientPayment();
    error ExcessivePayment();
    error SendFundsFailed();
    error InsufficientHoldings();
    error TransferToZeroAddress();
    error IncorrectSender();
    error InsufficientAllowance();
    error ZoneTokenNotSet();

/**
 * @title AlienzoneWearables V2.3
 * @author lixingyu.eth <@0xlxy>
 * @dev V2.3: True quadratic bounded curve (x²) replacing the hyperbolic curve of V2.2.
 *
 * Bonding curve parameters:
 *   - supplyFactor: total supply (plain integer, e.g. 20 for Epic)
 *   - curveFactor: IGNORED — kept for ABI compatibility, pass any value (e.g. 100)
 *   - initialPriceFactor: price at supply=0 in wei (e.g. parseEther("100") for Epic)
 *   - ceilPriceFactor: asymptotic max price per unit in wei (e.g. parseEther("5000") for Epic)
 *   - floorPriceFactor: min sell price per unit in wei (e.g. parseEther("99") for Epic)
 *
 * Rarity presets (all price values in wei):
 *   Common:     supply=160, curve=100(ignored), init=12.5,  ceil=625,   floor=11.5
 *   Uncommon:   supply=80,  curve=100(ignored), init=25,    ceil=1250,  floor=24
 *   Rare:       supply=40,  curve=100(ignored), init=50,    ceil=2500,  floor=49
 *   Epic:       supply=20,  curve=100(ignored), init=100,   ceil=5000,  floor=99
 *   Legendary:  supply=10,  curve=100(ignored), init=200,   ceil=10000, floor=199
 */
contract AlienzoneWearables is Initializable, Ownable, ReentrancyGuard {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    enum SaleStates {
        PRIVATE,
        PUBLIC
    }

    // 2.25% in bps
    uint16 private constant CREATOR_FEE_BPS_DEFAULT = 225;
    // 0.25% in bps
    uint16 private constant PROTOCOL_FEE_BPS_DEFAULT = 25;

    // Max combined fee = 20% (2000 bps)
    uint16 private constant MAX_COMBINED_FEE_BPS = 2000;

    // Base unit of a wearable. 1000 fractional shares = 1 full wearable
    uint256 private constant BASE_WEARABLE_UNIT = 0.001 ether;

    // ZONE token contract
    IERC20 public zoneToken;

    // Address of the protocol fee destination
    address public protocolFeeDestination;

    // Percentages (in bps)
    uint16 public protocolFeeBps;
    uint16 public creatorFeeBps;

    // Address that signs messages used for creating wearables and private sales
    address public wearableSigner;

    // Address that signs messages used for creating wearables
    address public wearableOperator;

    event ProtocolFeeDestinationUpdated(address feeDestination);
    event ProtocolFeeBpsUpdated(uint256 feePercent);
    event CreatorFeeBpsUpdated(uint256 feePercent);
    event WearableSignerUpdated(address signer);
    event WearableOperatorUpdated(address operator);
    event ZoneTokenUpdated(address zoneToken);
    event WearableSaleStateUpdated(bytes32 indexed wearablesSubject, SaleStates saleState);

    event WearableCreated(
        address indexed creator,
        bytes32 indexed subject,
        string name,
        string metadata,
        WearableFactors factors,
        SaleStates state
    );

    event Trade(
        address indexed trader,
        bytes32 indexed subject,
        bool isBuy,
        bool isPublic,
        uint256 wearableAmount,
        uint256 zoneAmount,
        uint256 protocolZoneAmount,
        uint256 creatorZoneAmount,
        uint256 supply
    );

    event NonceUpdated(address indexed user, uint256 nonce);
    event WearableTransferred(address indexed from, address indexed to, bytes32 indexed subject, uint256 amount);

    struct WearableFactors {
        uint256 supplyFactor;       // Total supply (plain integer, e.g. 20)
        uint256 curveFactor;        // IGNORED in V2.3 — kept for ABI compatibility (pass 100)
        uint256 initialPriceFactor; // Base price per unit in wei (e.g. 100 ether for Epic)
        uint256 ceilPriceFactor;    // Asymptotic max buy price in wei (e.g. 5000 ether for Epic)
        uint256 floorPriceFactor;   // Min sell price per unit in wei (e.g. 99 ether for Epic)
    }

    struct CreateWearableParams {
        address creator;
        string name;
        string metadata;
        bool isPublic;
        uint256 supplyFactor;       // Plain integer (e.g. 20)
        uint256 curveFactor;        // IGNORED — kept for ABI compatibility (pass 100)
        uint256 initialPriceFactor; // In wei (e.g. parseEther("100"))
        uint256 ceilPriceFactor;    // In wei (e.g. parseEther("5000"))
        uint256 floorPriceFactor;   // In wei (e.g. parseEther("99"))
    }

    struct Wearable {
        address creator;
        string name;
        string metadata;
        WearableFactors factors;
        SaleStates state;
    }

    // wearablesSubject => Wearable
    mapping(bytes32 => Wearable) public wearables;

    // wearablesSubject => (holder => balance)
    mapping(bytes32 => mapping(address => uint256)) public wearablesBalance;

    // wearablesSubject => supply
    mapping(bytes32 => uint256) public wearablesSupply;

    // userAddress => nonce
    mapping(address => uint256) public nonces;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address Owner) Ownable(Owner) {
        _disableInitializers();
    }

    function initialize(address _wearableOperator, address _signer, address _zoneToken, address _protocolFeeDestination) public initializer {
        protocolFeeDestination = _protocolFeeDestination;
        protocolFeeBps = PROTOCOL_FEE_BPS_DEFAULT;
        creatorFeeBps = CREATOR_FEE_BPS_DEFAULT;
        wearableOperator = _wearableOperator;
        wearableSigner = _signer;
        zoneToken = IERC20(_zoneToken);
    }

    // =========================================================================
    //                          Protocol Settings
    // =========================================================================

    function setZoneToken(address _zoneToken) external onlyOwner {
        if (_zoneToken == address(0)) revert TransferToZeroAddress();
        zoneToken = IERC20(_zoneToken);
        emit ZoneTokenUpdated(_zoneToken);
    }

    function setProtocolFeeDestination(address _feeDestination) external onlyOwner {
        if (_feeDestination == address(0)) revert TransferToZeroAddress();
        protocolFeeDestination = _feeDestination;
        emit ProtocolFeeDestinationUpdated(_feeDestination);
    }

    function setProtocolFeeBps(uint16 _feeBps) external onlyOwner {
        if (uint256(_feeBps) + uint256(creatorFeeBps) > MAX_COMBINED_FEE_BPS) revert InvalidFeePercent();
        protocolFeeBps = _feeBps;
        emit ProtocolFeeBpsUpdated(_feeBps);
    }

    function setCreatorFeeBps(uint16 _feeBps) external onlyOwner {
        if (uint256(_feeBps) + uint256(protocolFeeBps) > MAX_COMBINED_FEE_BPS) revert InvalidFeePercent();
        creatorFeeBps = _feeBps;
        emit CreatorFeeBpsUpdated(_feeBps);
    }

    function setWearableSigner(address _signer) external onlyOwner {
        if (_signer == address(0)) revert TransferToZeroAddress();
        wearableSigner = _signer;
        emit WearableSignerUpdated(_signer);
    }

    function setWearableOperator(address _operator) external onlyOwner {
        if (_operator == address(0)) revert TransferToZeroAddress();
        wearableOperator = _operator;
        emit WearableOperatorUpdated(_operator);
    }

    // =========================================================================
    //                          Create Wearable Logic
    // =========================================================================

    /// @dev Creates a wearable. operator only.
    function createWearable(CreateWearableParams calldata params) external {
        {
            if (msg.sender != wearableOperator) revert InvalidOperator();

            if (params.supplyFactor < 1 || params.supplyFactor > 10000) revert InvalidTotalSupply();
            // curveFactor validation kept for ABI compatibility (value is not used in pricing)
            if (params.curveFactor < 1 || params.curveFactor > 1000) revert InvalidCurveFactor();

            // All price factors must be in wei (>= 0.001 ether minimum)
            if (params.initialPriceFactor < 0.001 ether || params.initialPriceFactor > 1_000_000 ether)
                revert InvalidInitialPriceFactor();

            // ceilPriceFactor must be >= initialPriceFactor (price only goes up)
            if (params.ceilPriceFactor < params.initialPriceFactor || params.ceilPriceFactor > 100_000_000 ether)
                revert InvalidCeilPriceFactor();

            // floorPriceFactor must be <= initialPriceFactor and > 0
            if (params.floorPriceFactor == 0 || params.floorPriceFactor > params.initialPriceFactor)
                revert InvalidFloorPriceFactor();
        }

        bytes32 wearablesSubject = keccak256(abi.encode(params.name, params.metadata));

        if (wearables[wearablesSubject].creator != address(0)) revert WearableAlreadyCreated();

        SaleStates state = params.isPublic ? SaleStates.PUBLIC : SaleStates.PRIVATE;

        WearableFactors memory factors = WearableFactors(
            params.supplyFactor,
            params.curveFactor,
            params.initialPriceFactor,
            params.ceilPriceFactor,
            params.floorPriceFactor
        );

        wearables[wearablesSubject] = Wearable(params.creator, params.name, params.metadata, factors, state);

        emit WearableCreated(params.creator, wearablesSubject, params.name, params.metadata, factors, state);
    }

    // =========================================================================
    //                          Wearables Settings
    // =========================================================================

    function setWearableSalesState(bytes32 wearablesSubject, SaleStates saleState) external {
        if (msg.sender != wearableOperator) revert InvalidOperator();
        wearables[wearablesSubject].state = saleState;
        emit WearableSaleStateUpdated(wearablesSubject, saleState);
    }

    function batchSetWearableSalesState(bytes32[] calldata wearablesSubjects, SaleStates saleState) external {
        if (msg.sender != wearableOperator) revert InvalidOperator();
        for (uint256 i = 0; i < wearablesSubjects.length; i++) {
            wearables[wearablesSubjects[i]].state = saleState;
            emit WearableSaleStateUpdated(wearablesSubjects[i], saleState);
        }
    }

    // =========================================================================
    //                          Trade Wearable Logic
    // =========================================================================

    /**
     * @dev True quadratic bounded pricing.
     *
     * Marginal price at supply s: P(s) = init + (ceil - init) × (s / S)²
     *
     * Total cost for buying `amount` starting at `supply`:
     *   ∫[supply, supply+amount] P(t) dt
     *   = init×amount + (ceil-init)×amount×(3s² + 3s×a + a²) / (3×S²)
     *
     * Uses 1e9 fixed-point normalization (ns = supply×1e9/S, na = amount×1e9/S)
     * to keep all intermediates within uint256 bounds.
     *
     * @param supply             Current supply in wei
     * @param amount             Amount to buy/sell in wei
     * @param totalSupply        Max supply in wei (supplyFactor × 1 ether)
     * @param initialPriceFactor Price at supply=0 in wei
     * @param ceilPriceFactor    Asymptotic max price in wei
     * @param floorPriceFactor   Min sell price in wei
     * @param isBuy              True for buy, false for sell
     * Note: curveFactor param (position 4) is ignored — kept unnamed for ABI compatibility
     */
    function getPrice(
        uint256 supply,
        uint256 amount,
        uint256 totalSupply,
        uint256,               // curveFactor — ignored
        uint256 initialPriceFactor,
        uint256 ceilPriceFactor,
        uint256 floorPriceFactor,
        bool isBuy
    ) public pure returns (uint256) {
        if (isBuy && supply + amount > totalSupply) revert TotalSupplyExceeded();
        if (!isBuy && supply >= totalSupply) revert TotalSupplyExceeded();

        // 1e9 fixed-point normalization: ns, na in [0, 1e9]
        uint256 ns = (supply * 1e9) / totalSupply;
        uint256 na = (amount * 1e9) / totalSupply;

        // Integral terms — each intermediate fits in uint256:
        //   ns*ns ≤ (1e9)² = 1e18
        //   sumTerms ≤ 7×(1e9)² = 7e18
        uint256 sumTerms = 3 * ns * ns + 3 * ns * na + na * na;

        // Base cost: init × amount / 1e18
        uint256 baseCost = (initialPriceFactor * amount) / 1e18;

        uint256 price = baseCost;

        if (ceilPriceFactor > initialPriceFactor) {
            // Quadratic cost: (ceil-init) × amount/1e18 × sumTerms / (3×1e18)
            // Max intermediate: ~1e22 × 1e20 × 7e18 / 3e18 ≈ 2e42 — safe within uint256
            uint256 curveCost = ((ceilPriceFactor - initialPriceFactor) * amount / 1e18) * sumTerms / (3 * 1e18);
            price = baseCost + curveCost;
        }

        // Safety bounds (rarely triggered — formula naturally stays within range)
        if (isBuy && ceilPriceFactor > 0) {
            uint256 maxPrice = (ceilPriceFactor * amount) / 1e18;
            if (price > maxPrice) price = maxPrice;
        }

        if (!isBuy && floorPriceFactor > 0) {
            uint256 minPrice = (floorPriceFactor * amount) / 1e18;
            if (price < minPrice) price = minPrice;
        }

        return price;
    }

    /**
     * @dev Returns the instantaneous (marginal) price per unit at current supply.
     *      P(supply) = init + (ceil - init) × (supply / totalSupply)²
     */
    function getSpotPrice(bytes32 wearablesSubject) external view returns (uint256) {
        WearableFactors memory f = wearables[wearablesSubject].factors;
        uint256 supply = wearablesSupply[wearablesSubject];
        uint256 totalSupply = f.supplyFactor * 1 ether;
        if (totalSupply == 0) return f.initialPriceFactor;
        uint256 ns = (supply * 1e9) / totalSupply; // 0 to 1e9
        // ns ∈ [0, 1e9], so ns*ns ∈ [0, 1e18] — fits in uint256
        uint256 ns2 = (ns * ns);                    // (supply/S)² × 1e18
        if (f.ceilPriceFactor <= f.initialPriceFactor) return f.initialPriceFactor;
        return f.initialPriceFactor + (f.ceilPriceFactor - f.initialPriceFactor) * ns2 / 1e18;
    }

    function getBuyPrice(bytes32 wearablesSubject, uint256 amount) public view returns (uint256) {
        WearableFactors memory f = wearables[wearablesSubject].factors;
        return getPrice(
            wearablesSupply[wearablesSubject],
            amount,
            f.supplyFactor * 1 ether,
            f.curveFactor,
            f.initialPriceFactor,
            f.ceilPriceFactor,
            f.floorPriceFactor,
            true
        );
    }

    function getSellPrice(bytes32 wearablesSubject, uint256 amount) public view returns (uint256) {
        WearableFactors memory f = wearables[wearablesSubject].factors;
        return getPrice(
            wearablesSupply[wearablesSubject] - amount,
            amount,
            f.supplyFactor * 1 ether,
            f.curveFactor,
            f.initialPriceFactor,
            f.ceilPriceFactor,
            f.floorPriceFactor,
            false
        );
    }

    function getBuyPriceAfterFee(bytes32 wearablesSubject, uint256 amount) external view returns (uint256) {
        uint256 price = getBuyPrice(wearablesSubject, amount);
        return price + _getProtocolFee(price, true) + _getCreatorFee(price, true);
    }

    function getSellPriceAfterFee(bytes32 wearablesSubject, uint256 amount) external view returns (uint256) {
        uint256 price = getSellPrice(wearablesSubject, amount);
        return price - _getProtocolFee(price, false) - _getCreatorFee(price, false);
    }

    function _getProtocolFee(uint256 price, bool roundUp) internal view returns (uint256) {
        return Math.mulDiv(price, protocolFeeBps, 10_000, roundUp ? Math.Rounding.Ceil : Math.Rounding.Floor);
    }

    function _getCreatorFee(uint256 price, bool roundUp) internal view returns (uint256) {
        return Math.mulDiv(price, creatorFeeBps, 10_000, roundUp ? Math.Rounding.Ceil : Math.Rounding.Floor);
    }

    function getUserNonce(address user) external view returns (uint256) {
        return nonces[user];
    }

    function buyWearables(bytes32 wearablesSubject, uint256 amount) external nonReentrant {
        {
            if (address(zoneToken) == address(0)) revert ZoneTokenNotSet();
            if (amount < BASE_WEARABLE_UNIT) revert InsufficientBaseUnit();
            if (amount % BASE_WEARABLE_UNIT != 0) revert AmountNotMultipleOfBaseUnit();
            if (wearables[wearablesSubject].creator == address(0)) revert WearableNotCreated();
            if (wearables[wearablesSubject].state != SaleStates.PUBLIC) revert InvalidSaleState();
        }
        _buyWearables(wearablesSubject, amount, true);
    }

    function buyPrivateWearables(bytes32 wearablesSubject, uint256 amount, bytes calldata signature) external nonReentrant {
        {
            if (address(zoneToken) == address(0)) revert ZoneTokenNotSet();
            if (amount < BASE_WEARABLE_UNIT) revert InsufficientBaseUnit();
            if (amount % BASE_WEARABLE_UNIT != 0) revert AmountNotMultipleOfBaseUnit();
            if (wearables[wearablesSubject].creator == address(0)) revert WearableNotCreated();
            if (wearables[wearablesSubject].state != SaleStates.PRIVATE) revert InvalidSaleState();

            uint256 nonce = nonces[msg.sender];
            bytes32 hashVal = keccak256(abi.encodePacked(block.chainid, address(this), msg.sender, "buy", wearablesSubject, amount, nonce));
            if (ECDSA.recover(hashVal, signature) != wearableSigner) revert InvalidSignature();

            nonces[msg.sender] += 1;
            emit NonceUpdated(msg.sender, nonces[msg.sender]);
        }
        _buyWearables(wearablesSubject, amount, false);
    }

    function _buyWearables(bytes32 wearablesSubject, uint256 amount, bool isPublic) internal {
        uint256 supply = wearablesSupply[wearablesSubject];
        WearableFactors memory f = wearables[wearablesSubject].factors;

        uint256 price = getPrice(
            supply, amount, f.supplyFactor * 1 ether,
            f.curveFactor, f.initialPriceFactor, f.ceilPriceFactor, f.floorPriceFactor, true
        );

        uint256 protocolFee = _getProtocolFee(price, true);
        uint256 creatorFee = _getCreatorFee(price, true);
        uint256 totalCost = price + protocolFee + creatorFee;

        if (zoneToken.balanceOf(msg.sender) < totalCost) revert InsufficientPayment();
        if (zoneToken.allowance(msg.sender, address(this)) < totalCost) revert InsufficientAllowance();

        address creatorFeeDestination = wearables[wearablesSubject].creator;
        if (protocolFeeDestination == address(0)) revert TransferToZeroAddress();
        if (creatorFeeDestination == address(0)) revert TransferToZeroAddress();

        wearablesBalance[wearablesSubject][msg.sender] += amount;
        wearablesSupply[wearablesSubject] = supply + amount;

        emit Trade(msg.sender, wearablesSubject, true, isPublic, amount, price, protocolFee, creatorFee, supply + amount);

        zoneToken.safeTransferFrom(msg.sender, address(this), totalCost);
        zoneToken.safeTransfer(protocolFeeDestination, protocolFee);
        zoneToken.safeTransfer(creatorFeeDestination, creatorFee);
    }

    function sellWearables(bytes32 wearablesSubject, uint256 amount) external nonReentrant {
        {
            if (address(zoneToken) == address(0)) revert ZoneTokenNotSet();
            if (amount < BASE_WEARABLE_UNIT) revert InsufficientBaseUnit();
            if (amount % BASE_WEARABLE_UNIT != 0) revert AmountNotMultipleOfBaseUnit();
            if (wearables[wearablesSubject].creator == address(0)) revert WearableNotCreated();
            if (wearables[wearablesSubject].state != SaleStates.PUBLIC) revert InvalidSaleState();
        }
        _sellWearables(wearablesSubject, amount, true);
    }

    function sellPrivateWearables(bytes32 wearablesSubject, uint256 amount, bytes calldata signature) external nonReentrant {
        {
            if (address(zoneToken) == address(0)) revert ZoneTokenNotSet();
            if (amount < BASE_WEARABLE_UNIT) revert InsufficientBaseUnit();
            if (amount % BASE_WEARABLE_UNIT != 0) revert AmountNotMultipleOfBaseUnit();
            if (wearables[wearablesSubject].creator == address(0)) revert WearableNotCreated();
            if (wearables[wearablesSubject].state != SaleStates.PRIVATE) revert InvalidSaleState();

            uint256 nonce = nonces[msg.sender];
            bytes32 hashVal = keccak256(abi.encodePacked(block.chainid, address(this), msg.sender, "sell", wearablesSubject, amount, nonce));
            if (ECDSA.recover(hashVal, signature) != wearableSigner) revert InvalidSignature();

            nonces[msg.sender] += 1;
            emit NonceUpdated(msg.sender, nonces[msg.sender]);
        }
        _sellWearables(wearablesSubject, amount, false);
    }

    function _sellWearables(bytes32 wearablesSubject, uint256 amount, bool isPublic) internal {
        uint256 supply = wearablesSupply[wearablesSubject];
        WearableFactors memory f = wearables[wearablesSubject].factors;

        uint256 price = getPrice(
            supply - amount, amount, f.supplyFactor * 1 ether,
            f.curveFactor, f.initialPriceFactor, f.ceilPriceFactor, f.floorPriceFactor, false
        );

        uint256 protocolFee = _getProtocolFee(price, false);
        uint256 creatorFee = _getCreatorFee(price, false);

        if (wearablesBalance[wearablesSubject][msg.sender] < amount) revert InsufficientHoldings();
        if (zoneToken.balanceOf(address(this)) < price - protocolFee - creatorFee) revert InsufficientPayment();

        address creatorFeeDestination = wearables[wearablesSubject].creator;
        if (protocolFeeDestination == address(0)) revert TransferToZeroAddress();
        if (creatorFeeDestination == address(0)) revert TransferToZeroAddress();

        wearablesBalance[wearablesSubject][msg.sender] -= amount;
        wearablesSupply[wearablesSubject] = supply - amount;

        emit Trade(msg.sender, wearablesSubject, false, isPublic, amount, price, protocolFee, creatorFee, supply - amount);

        zoneToken.safeTransfer(msg.sender, price - protocolFee - creatorFee);
        zoneToken.safeTransfer(protocolFeeDestination, protocolFee);
        zoneToken.safeTransfer(creatorFeeDestination, creatorFee);
    }

    function transferWearables(bytes32 wearablesSubject, address from, address to, uint256 amount) external nonReentrant {
        if (to == address(0)) revert TransferToZeroAddress();
        if (amount < BASE_WEARABLE_UNIT) revert InsufficientBaseUnit();
        if (amount % BASE_WEARABLE_UNIT != 0) revert AmountNotMultipleOfBaseUnit();
        if (_msgSender() != from) revert IncorrectSender();
        if (wearablesBalance[wearablesSubject][from] < amount) revert InsufficientHoldings();

        wearablesBalance[wearablesSubject][from] -= amount;
        wearablesBalance[wearablesSubject][to] += amount;

        emit WearableTransferred(from, to, wearablesSubject, amount);
    }

    function withdrawZoneTokens(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert TransferToZeroAddress();
        zoneToken.safeTransfer(to, amount);
    }
}
