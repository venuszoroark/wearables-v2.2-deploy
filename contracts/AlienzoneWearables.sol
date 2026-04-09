// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Version: V2.2
// Changes from V2.1:
//   - Added ceilPriceFactor (max buy price per unit in wei)
//   - Added floorPriceFactor (min sell price per unit in wei)
//   - Removed Initializable/proxy pattern — constructor handles init

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

contract AlienzoneWearables is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    enum SaleStates { PRIVATE, PUBLIC }

    uint16 private constant CREATOR_FEE_BPS_DEFAULT = 225;
    uint16 private constant PROTOCOL_FEE_BPS_DEFAULT = 25;
    uint16 private constant MAX_COMBINED_FEE_BPS = 2000;
    uint256 private constant BASE_WEARABLE_UNIT = 0.001 ether;

    IERC20 public zoneToken;
    address public protocolFeeDestination;
    uint16 public protocolFeeBps;
    uint16 public creatorFeeBps;
    address public wearableSigner;
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
        uint256 supplyFactor;
        uint256 curveFactor;
        uint256 initialPriceFactor;
        uint256 ceilPriceFactor;
        uint256 floorPriceFactor;
    }

    struct CreateWearableParams {
        address creator;
        string name;
        string metadata;
        bool isPublic;
        uint256 supplyFactor;
        uint256 curveFactor;
        uint256 initialPriceFactor;
        uint256 ceilPriceFactor;
        uint256 floorPriceFactor;
    }

    struct Wearable {
        address creator;
        string name;
        string metadata;
        WearableFactors factors;
        SaleStates state;
    }

    mapping(bytes32 => Wearable) public wearables;
    mapping(bytes32 => mapping(address => uint256)) public wearablesBalance;
    mapping(bytes32 => uint256) public wearablesSupply;
    mapping(address => uint256) public nonces;

    constructor(
        address _owner,
        address _operator,
        address _signer,
        address _zoneToken,
        address _feeDestination
    ) Ownable(_owner) {
        protocolFeeDestination = _feeDestination;
        protocolFeeBps = PROTOCOL_FEE_BPS_DEFAULT;
        creatorFeeBps = CREATOR_FEE_BPS_DEFAULT;
        wearableOperator = _operator;
        wearableSigner = _signer;
        zoneToken = IERC20(_zoneToken);
    }

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

    function createWearable(CreateWearableParams calldata params) external {
        if (msg.sender != wearableOperator) revert InvalidOperator();
        if (params.supplyFactor < 1 || params.supplyFactor > 10000) revert InvalidTotalSupply();
        if (params.curveFactor < 1 || params.curveFactor > 1000) revert InvalidCurveFactor();
        if (params.initialPriceFactor < 0.001 ether || params.initialPriceFactor > 1_000_000 ether) revert InvalidInitialPriceFactor();
        if (params.ceilPriceFactor < params.initialPriceFactor || params.ceilPriceFactor > 100_000_000 ether) revert InvalidCeilPriceFactor();
        if (params.floorPriceFactor == 0 || params.floorPriceFactor > params.initialPriceFactor) revert InvalidFloorPriceFactor();

        bytes32 wearablesSubject = keccak256(abi.encode(params.name, params.metadata));
        if (wearables[wearablesSubject].creator != address(0)) revert WearableAlreadyCreated();

        SaleStates state = params.isPublic ? SaleStates.PUBLIC : SaleStates.PRIVATE;
        WearableFactors memory factors = WearableFactors(
            params.supplyFactor, params.curveFactor, params.initialPriceFactor,
            params.ceilPriceFactor, params.floorPriceFactor
        );
        wearables[wearablesSubject] = Wearable(params.creator, params.name, params.metadata, factors, state);
        emit WearableCreated(params.creator, wearablesSubject, params.name, params.metadata, factors, state);
    }

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

    function _curve(uint256 x, uint256 totalSupply, uint256 curveFactor, uint256 initialPriceFactor) internal pure returns (uint256) {
        uint256 curvePrice = ((totalSupply * curveFactor * 1e18) / (totalSupply - x)) - (curveFactor * 1e18);
        uint256 basePrice = (initialPriceFactor * x) / 1 ether;
        return curvePrice + basePrice;
    }

    function getPrice(
        uint256 supply, uint256 amount, uint256 totalSupply,
        uint256 curveFactor, uint256 initialPriceFactor,
        uint256 ceilPriceFactor, uint256 floorPriceFactor, bool isBuy
    ) public pure returns (uint256) {
        if (isBuy && supply + amount >= totalSupply) revert TotalSupplyExceeded();
        if (!isBuy && supply >= totalSupply) revert TotalSupplyExceeded();

        uint256 price = _curve(supply + amount, totalSupply, curveFactor, initialPriceFactor)
            - _curve(supply, totalSupply, curveFactor, initialPriceFactor);

        if (isBuy && ceilPriceFactor > 0) {
            uint256 maxPrice = (ceilPriceFactor * amount) / 1 ether;
            if (price > maxPrice) price = maxPrice;
        }
        if (!isBuy && floorPriceFactor > 0) {
            uint256 minPrice = (floorPriceFactor * amount) / 1 ether;
            if (price < minPrice) price = minPrice;
        }
        return price;
    }

    function getBuyPrice(bytes32 wearablesSubject, uint256 amount) public view returns (uint256) {
        WearableFactors memory f = wearables[wearablesSubject].factors;
        return getPrice(wearablesSupply[wearablesSubject], amount, f.supplyFactor * 1 ether, f.curveFactor, f.initialPriceFactor, f.ceilPriceFactor, f.floorPriceFactor, true);
    }

    function getSellPrice(bytes32 wearablesSubject, uint256 amount) public view returns (uint256) {
        WearableFactors memory f = wearables[wearablesSubject].factors;
        return getPrice(wearablesSupply[wearablesSubject] - amount, amount, f.supplyFactor * 1 ether, f.curveFactor, f.initialPriceFactor, f.ceilPriceFactor, f.floorPriceFactor, false);
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

    function getUserNonce(address user) external view returns (uint256) { return nonces[user]; }

    function buyWearables(bytes32 wearablesSubject, uint256 amount) external nonReentrant {
        if (address(zoneToken) == address(0)) revert ZoneTokenNotSet();
        if (amount < BASE_WEARABLE_UNIT) revert InsufficientBaseUnit();
        if (amount % BASE_WEARABLE_UNIT != 0) revert AmountNotMultipleOfBaseUnit();
        if (wearables[wearablesSubject].creator == address(0)) revert WearableNotCreated();
        if (wearables[wearablesSubject].state != SaleStates.PUBLIC) revert InvalidSaleState();
        _buyWearables(wearablesSubject, amount, true);
    }

    function buyPrivateWearables(bytes32 wearablesSubject, uint256 amount, bytes calldata signature) external nonReentrant {
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
        _buyWearables(wearablesSubject, amount, false);
    }

    function _buyWearables(bytes32 wearablesSubject, uint256 amount, bool isPublic) internal {
        uint256 supply = wearablesSupply[wearablesSubject];
        WearableFactors memory f = wearables[wearablesSubject].factors;
        uint256 price = getPrice(supply, amount, f.supplyFactor * 1 ether, f.curveFactor, f.initialPriceFactor, f.ceilPriceFactor, f.floorPriceFactor, true);
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
        if (address(zoneToken) == address(0)) revert ZoneTokenNotSet();
        if (amount < BASE_WEARABLE_UNIT) revert InsufficientBaseUnit();
        if (amount % BASE_WEARABLE_UNIT != 0) revert AmountNotMultipleOfBaseUnit();
        if (wearables[wearablesSubject].creator == address(0)) revert WearableNotCreated();
        if (wearables[wearablesSubject].state != SaleStates.PUBLIC) revert InvalidSaleState();
        _sellWearables(wearablesSubject, amount, true);
    }

    function sellPrivateWearables(bytes32 wearablesSubject, uint256 amount, bytes calldata signature) external nonReentrant {
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
        _sellWearables(wearablesSubject, amount, false);
    }

    function _sellWearables(bytes32 wearablesSubject, uint256 amount, bool isPublic) internal {
        uint256 supply = wearablesSupply[wearablesSubject];
        WearableFactors memory f = wearables[wearablesSubject].factors;
        uint256 price = getPrice(supply - amount, amount, f.supplyFactor * 1 ether, f.curveFactor, f.initialPriceFactor, f.ceilPriceFactor, f.floorPriceFactor, false);
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
