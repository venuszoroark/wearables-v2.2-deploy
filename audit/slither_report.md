'solc --version' running
'solc @openzeppelin/=node_modules/@openzeppelin/ contracts/AlienzoneWearablesV2.3.sol --combined-json abi,ast,bin,bin-runtime,srcmap,srcmap-runtime,userdoc,devdoc,hashes --via-ir --optimize --optimize-runs 200 --allow-paths .,/tmp/wearables-v2.2-deploy/contracts' running

Detector: incorrect-exp
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) has bitwise-xor operator ^ instead of the exponentiation operator **: 
	 - inverse = (3 * denominator) ^ 2 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#259)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-exponentiation

Detector: divide-before-multiply
AlienzoneWearables.getPrice(uint256,uint256,uint256,uint256,uint256,uint256,uint256,bool) (contracts/AlienzoneWearablesV2.3.sol#323-369) performs a multiplication on the result of a division:
	- na = (amount * 1e9) / totalSupply (contracts/AlienzoneWearablesV2.3.sol#338)
	- sumTerms = 3 * ns * ns + 3 * ns * na + na * na (contracts/AlienzoneWearablesV2.3.sol#343)
AlienzoneWearables.getPrice(uint256,uint256,uint256,uint256,uint256,uint256,uint256,bool) (contracts/AlienzoneWearablesV2.3.sol#323-369) performs a multiplication on the result of a division:
	- curveCost = ((ceilPriceFactor - initialPriceFactor) * amount / 1e18) * sumTerms / (3 * 1e18) (contracts/AlienzoneWearablesV2.3.sol#353)
AlienzoneWearables.getSpotPrice(bytes32) (contracts/AlienzoneWearablesV2.3.sol#375-385) performs a multiplication on the result of a division:
	- ns = (supply * 1e9) / totalSupply (contracts/AlienzoneWearablesV2.3.sol#380)
	- ns2 = (ns * ns) (contracts/AlienzoneWearablesV2.3.sol#382)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#244)
	- inverse = (3 * denominator) ^ 2 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#259)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#244)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#263)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#244)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#264)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#244)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#265)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#244)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#266)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#244)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#267)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- denominator = denominator / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#244)
	- inverse *= 2 - denominator * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#268)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) performs a multiplication on the result of a division:
	- low = low / twos (node_modules/@openzeppelin/contracts/utils/math/Math.sol#247)
	- result = low * inverse (node_modules/@openzeppelin/contracts/utils/math/Math.sol#274)
Math.invMod(uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#317-363) performs a multiplication on the result of a division:
	- quotient = gcd / remainder (node_modules/@openzeppelin/contracts/utils/math/Math.sol#339)
	- (gcd,remainder) = (remainder,gcd - remainder * quotient) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#341-348)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply

Detector: shadowing-local
AlienzoneWearables.constructor(address,address,address,address,address)._owner (contracts/AlienzoneWearablesV2.3.sol#181) shadows:
	- Ownable._owner (node_modules/@openzeppelin/contracts/access/Ownable.sol#21) (state variable)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing

Detector: missing-zero-check
AlienzoneWearables.constructor(address,address,address,address,address)._feeDestination (contracts/AlienzoneWearablesV2.3.sol#185) lacks a zero-check on :
		- protocolFeeDestination = _feeDestination (contracts/AlienzoneWearablesV2.3.sol#187)
AlienzoneWearables.constructor(address,address,address,address,address)._operator (contracts/AlienzoneWearablesV2.3.sol#182) lacks a zero-check on :
		- wearableOperator = _operator (contracts/AlienzoneWearablesV2.3.sol#190)
AlienzoneWearables.constructor(address,address,address,address,address)._signer (contracts/AlienzoneWearablesV2.3.sol#183) lacks a zero-check on :
		- wearableSigner = _signer (contracts/AlienzoneWearablesV2.3.sol#191)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation

Detector: assembly
SafeERC20._safeTransfer(IERC20,address,uint256,bool) (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#176-200) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#179-199)
SafeERC20._safeTransferFrom(IERC20,address,address,uint256,bool) (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#212-244) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#221-243)
SafeERC20._safeApprove(IERC20,address,uint256,bool) (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#255-279) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#258-278)
Panic.panic(uint256) (node_modules/@openzeppelin/contracts/utils/Panic.sol#50-56) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/Panic.sol#51-55)
StorageSlot.getAddressSlot(bytes32) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#66-70) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#67-69)
StorageSlot.getBooleanSlot(bytes32) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#75-79) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#76-78)
StorageSlot.getBytes32Slot(bytes32) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#84-88) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#85-87)
StorageSlot.getUint256Slot(bytes32) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#93-97) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#94-96)
StorageSlot.getInt256Slot(bytes32) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#102-106) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#103-105)
StorageSlot.getStringSlot(bytes32) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#111-115) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#112-114)
StorageSlot.getStringSlot(string) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#120-124) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#121-123)
StorageSlot.getBytesSlot(bytes32) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#129-133) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#130-132)
StorageSlot.getBytesSlot(bytes) (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#138-142) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#139-141)
ECDSA.tryRecover(bytes32,bytes) (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#61-80) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#71-75)
ECDSA.tryRecoverCalldata(bytes32,bytes) (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#85-104) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#95-99)
ECDSA.parse(bytes) (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#217-240) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#218-239)
ECDSA.parseCalldata(bytes) (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#245-268) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#246-267)
Math.add512(uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#25-30) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#26-29)
Math.mul512(uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#37-46) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#41-45)
Math.tryMul(uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#73-84) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#76-80)
Math.tryDiv(uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#89-97) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#92-95)
Math.tryMod(uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#102-110) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#105-108)
Math.mulDiv(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#206-277) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#229-236)
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#242-251)
Math.tryModExp(uint256,uint256,uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#411-435) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#413-434)
Math.tryModExp(bytes,bytes,bytes) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#451-473) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#463-472)
Math._zeroBytes(bytes) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#478-490) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#482-484)
Math.log2(uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#619-658) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/Math.sol#655-657)
SafeCast.toUint(bool) (node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#1157-1161) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#1158-1160)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage

Detector: pragma
4 different versions of Solidity are used:
	- Version constraint ^0.8.26 is used by:
		-^0.8.26 (contracts/AlienzoneWearablesV2.3.sol#2)
	- Version constraint ^0.8.20 is used by:
		-^0.8.20 (node_modules/@openzeppelin/contracts/access/Ownable.sol#4)
		-^0.8.20 (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#4)
		-^0.8.20 (node_modules/@openzeppelin/contracts/utils/Context.sol#4)
		-^0.8.20 (node_modules/@openzeppelin/contracts/utils/Panic.sol#4)
		-^0.8.20 (node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol#4)
		-^0.8.20 (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#5)
		-^0.8.20 (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#4)
		-^0.8.20 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#4)
		-^0.8.20 (node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#5)
	- Version constraint >=0.6.2 is used by:
		->=0.6.2 (node_modules/@openzeppelin/contracts/interfaces/IERC1363.sol#4)
	- Version constraint >=0.4.16 is used by:
		->=0.4.16 (node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#4)
		->=0.4.16 (node_modules/@openzeppelin/contracts/interfaces/IERC20.sol#4)
		->=0.4.16 (node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#4)
		->=0.4.16 (node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#4)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used

Detector: dead-code
Context._contextSuffixLength() (node_modules/@openzeppelin/contracts/utils/Context.sol#25-27) is never used and should be removed
Context._msgData() (node_modules/@openzeppelin/contracts/utils/Context.sol#21-23) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code

Detector: solc-version
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- ^0.8.20 (node_modules/@openzeppelin/contracts/access/Ownable.sol#4)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#4)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/utils/Context.sol#4)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/utils/Panic.sol#4)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol#4)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#5)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#4)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/utils/math/Math.sol#4)
	- ^0.8.20 (node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#5)
Version constraint >=0.6.2 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- NestedCalldataArrayAbiReencodingSizeValidation
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- MissingEscapingInFormatting
	- ArraySliceDynamicallyEncodedBaseType
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow.
It is used by:
	- >=0.6.2 (node_modules/@openzeppelin/contracts/interfaces/IERC1363.sol#4)
Version constraint >=0.4.16 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- DirtyBytesArrayToStorage
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow
	- privateCanBeOverridden
	- SignedArrayStorageCopy
	- ABIEncoderV2StorageArrayWithMultiSlotElement
	- DynamicConstructorArgumentsClippedABIV2
	- UninitializedFunctionPointerInConstructor_0.4.x
	- IncorrectEventSignatureInLibraries_0.4.x
	- ExpExponentCleanup
	- NestedArrayFunctionCallDecoder
	- ZeroFunctionSelector.
It is used by:
	- >=0.4.16 (node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#4)
	- >=0.4.16 (node_modules/@openzeppelin/contracts/interfaces/IERC20.sol#4)
	- >=0.4.16 (node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#4)
	- >=0.4.16 (node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#4)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

Detector: naming-convention
Parameter AlienzoneWearables.setZoneToken(address)._zoneToken (contracts/AlienzoneWearablesV2.3.sol#199) is not in mixedCase
Parameter AlienzoneWearables.setProtocolFeeDestination(address)._feeDestination (contracts/AlienzoneWearablesV2.3.sol#205) is not in mixedCase
Parameter AlienzoneWearables.setProtocolFeeBps(uint16)._feeBps (contracts/AlienzoneWearablesV2.3.sol#211) is not in mixedCase
Parameter AlienzoneWearables.setCreatorFeeBps(uint16)._feeBps (contracts/AlienzoneWearablesV2.3.sol#217) is not in mixedCase
Parameter AlienzoneWearables.setWearableSigner(address)._signer (contracts/AlienzoneWearablesV2.3.sol#223) is not in mixedCase
Parameter AlienzoneWearables.setWearableOperator(address)._operator (contracts/AlienzoneWearablesV2.3.sol#229) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

Detector: too-many-digits
Math.log2(uint256) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#619-658) uses literals with too many digits:
	- r = r | byte(uint256,uint256)(x >> r,0x0000010102020202030303030303030300000000000000000000000000000000) (node_modules/@openzeppelin/contracts/utils/math/Math.sol#656)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#too-many-digits

Detector: unindexed-event-address
Event AlienzoneWearables.ProtocolFeeDestinationUpdated(address) (contracts/AlienzoneWearablesV2.3.sol#108) has address parameters but no indexed parameters
Event AlienzoneWearables.WearableSignerUpdated(address) (contracts/AlienzoneWearablesV2.3.sol#111) has address parameters but no indexed parameters
Event AlienzoneWearables.WearableOperatorUpdated(address) (contracts/AlienzoneWearablesV2.3.sol#112) has address parameters but no indexed parameters
Event AlienzoneWearables.ZoneTokenUpdated(address) (contracts/AlienzoneWearablesV2.3.sol#113) has address parameters but no indexed parameters
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unindexed-event-address-parameters
**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [incorrect-exp](#incorrect-exp) (1 results) (High)
 - [divide-before-multiply](#divide-before-multiply) (12 results) (Medium)
 - [shadowing-local](#shadowing-local) (1 results) (Low)
 - [missing-zero-check](#missing-zero-check) (3 results) (Low)
 - [assembly](#assembly) (28 results) (Informational)
 - [pragma](#pragma) (1 results) (Informational)
 - [dead-code](#dead-code) (2 results) (Informational)
 - [solc-version](#solc-version) (3 results) (Informational)
 - [naming-convention](#naming-convention) (6 results) (Informational)
 - [too-many-digits](#too-many-digits) (1 results) (Informational)
 - [unindexed-event-address](#unindexed-event-address) (4 results) (Informational)
## incorrect-exp
Impact: High
Confidence: Medium
 - [ ] ID-0
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) has bitwise-xor operator ^ instead of the exponentiation operator **: 
	 - [inverse = (3 * denominator) ^ 2](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L259)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


## divide-before-multiply
Impact: Medium
Confidence: Medium
 - [ ] ID-1
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [low = low / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L247)
	- [result = low * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L274)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-2
[Math.invMod(uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L317-L363) performs a multiplication on the result of a division:
	- [quotient = gcd / remainder](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L339)
	- [(gcd,remainder) = (remainder,gcd - remainder * quotient)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L341-L348)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L317-L363


 - [ ] ID-3
[AlienzoneWearables.getPrice(uint256,uint256,uint256,uint256,uint256,uint256,uint256,bool)](contracts/AlienzoneWearablesV2.3.sol#L323-L369) performs a multiplication on the result of a division:
	- [curveCost = ((ceilPriceFactor - initialPriceFactor) * amount / 1e18) * sumTerms / (3 * 1e18)](contracts/AlienzoneWearablesV2.3.sol#L353)

contracts/AlienzoneWearablesV2.3.sol#L323-L369


 - [ ] ID-4
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L244)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L268)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-5
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L244)
	- [inverse = (3 * denominator) ^ 2](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L259)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-6
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L244)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L266)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-7
[AlienzoneWearables.getPrice(uint256,uint256,uint256,uint256,uint256,uint256,uint256,bool)](contracts/AlienzoneWearablesV2.3.sol#L323-L369) performs a multiplication on the result of a division:
	- [na = (amount * 1e9) / totalSupply](contracts/AlienzoneWearablesV2.3.sol#L338)
	- [sumTerms = 3 * ns * ns + 3 * ns * na + na * na](contracts/AlienzoneWearablesV2.3.sol#L343)

contracts/AlienzoneWearablesV2.3.sol#L323-L369


 - [ ] ID-8
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L244)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L267)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-9
[AlienzoneWearables.getSpotPrice(bytes32)](contracts/AlienzoneWearablesV2.3.sol#L375-L385) performs a multiplication on the result of a division:
	- [ns = (supply * 1e9) / totalSupply](contracts/AlienzoneWearablesV2.3.sol#L380)
	- [ns2 = (ns * ns)](contracts/AlienzoneWearablesV2.3.sol#L382)

contracts/AlienzoneWearablesV2.3.sol#L375-L385


 - [ ] ID-10
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L244)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L264)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-11
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L244)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L263)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-12
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) performs a multiplication on the result of a division:
	- [denominator = denominator / twos](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L244)
	- [inverse *= 2 - denominator * inverse](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L265)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


## shadowing-local
Impact: Low
Confidence: High
 - [ ] ID-13
[AlienzoneWearables.constructor(address,address,address,address,address)._owner](contracts/AlienzoneWearablesV2.3.sol#L181) shadows:
	- [Ownable._owner](node_modules/@openzeppelin/contracts/access/Ownable.sol#L21) (state variable)

contracts/AlienzoneWearablesV2.3.sol#L181


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-14
[AlienzoneWearables.constructor(address,address,address,address,address)._feeDestination](contracts/AlienzoneWearablesV2.3.sol#L185) lacks a zero-check on :
		- [protocolFeeDestination = _feeDestination](contracts/AlienzoneWearablesV2.3.sol#L187)

contracts/AlienzoneWearablesV2.3.sol#L185


 - [ ] ID-15
[AlienzoneWearables.constructor(address,address,address,address,address)._operator](contracts/AlienzoneWearablesV2.3.sol#L182) lacks a zero-check on :
		- [wearableOperator = _operator](contracts/AlienzoneWearablesV2.3.sol#L190)

contracts/AlienzoneWearablesV2.3.sol#L182


 - [ ] ID-16
[AlienzoneWearables.constructor(address,address,address,address,address)._signer](contracts/AlienzoneWearablesV2.3.sol#L183) lacks a zero-check on :
		- [wearableSigner = _signer](contracts/AlienzoneWearablesV2.3.sol#L191)

contracts/AlienzoneWearablesV2.3.sol#L183


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-17
[SafeCast.toUint(bool)](node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#L1157-L1161) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#L1158-L1160)

node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#L1157-L1161


 - [ ] ID-18
[StorageSlot.getAddressSlot(bytes32)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L66-L70) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L67-L69)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L66-L70


 - [ ] ID-19
[SafeERC20._safeTransfer(IERC20,address,uint256,bool)](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L176-L200) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L179-L199)

node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L176-L200


 - [ ] ID-20
[ECDSA.tryRecoverCalldata(bytes32,bytes)](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L85-L104) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L95-L99)

node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L85-L104


 - [ ] ID-21
[Math.tryModExp(bytes,bytes,bytes)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L451-L473) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L463-L472)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L451-L473


 - [ ] ID-22
[StorageSlot.getUint256Slot(bytes32)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L93-L97) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L94-L96)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L93-L97


 - [ ] ID-23
[Math.log2(uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L619-L658) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L655-L657)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L619-L658


 - [ ] ID-24
[StorageSlot.getBooleanSlot(bytes32)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L75-L79) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L76-L78)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L75-L79


 - [ ] ID-25
[ECDSA.parseCalldata(bytes)](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L245-L268) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L246-L267)

node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L245-L268


 - [ ] ID-26
[StorageSlot.getBytes32Slot(bytes32)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L84-L88) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L85-L87)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L84-L88


 - [ ] ID-27
[SafeERC20._safeApprove(IERC20,address,uint256,bool)](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L255-L279) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L258-L278)

node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L255-L279


 - [ ] ID-28
[Panic.panic(uint256)](node_modules/@openzeppelin/contracts/utils/Panic.sol#L50-L56) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/Panic.sol#L51-L55)

node_modules/@openzeppelin/contracts/utils/Panic.sol#L50-L56


 - [ ] ID-29
[StorageSlot.getInt256Slot(bytes32)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L102-L106) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L103-L105)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L102-L106


 - [ ] ID-30
[StorageSlot.getBytesSlot(bytes)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L138-L142) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L139-L141)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L138-L142


 - [ ] ID-31
[Math.mulDiv(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L229-L236)
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L242-L251)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L206-L277


 - [ ] ID-32
[Math.mul512(uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L37-L46) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L41-L45)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L37-L46


 - [ ] ID-33
[StorageSlot.getStringSlot(bytes32)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L111-L115) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L112-L114)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L111-L115


 - [ ] ID-34
[ECDSA.parse(bytes)](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L217-L240) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L218-L239)

node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L217-L240


 - [ ] ID-35
[ECDSA.tryRecover(bytes32,bytes)](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L61-L80) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L71-L75)

node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L61-L80


 - [ ] ID-36
[StorageSlot.getStringSlot(string)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L120-L124) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L121-L123)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L120-L124


 - [ ] ID-37
[Math.tryMul(uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L73-L84) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L76-L80)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L73-L84


 - [ ] ID-38
[Math.tryMod(uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L102-L110) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L105-L108)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L102-L110


 - [ ] ID-39
[Math.tryDiv(uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L89-L97) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L92-L95)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L89-L97


 - [ ] ID-40
[StorageSlot.getBytesSlot(bytes32)](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L129-L133) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L130-L132)

node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L129-L133


 - [ ] ID-41
[Math._zeroBytes(bytes)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L478-L490) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L482-L484)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L478-L490


 - [ ] ID-42
[Math.tryModExp(uint256,uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L411-L435) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L413-L434)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L411-L435


 - [ ] ID-43
[SafeERC20._safeTransferFrom(IERC20,address,address,uint256,bool)](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L212-L244) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L221-L243)

node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L212-L244


 - [ ] ID-44
[Math.add512(uint256,uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L25-L30) uses assembly
	- [INLINE ASM](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L26-L29)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L25-L30


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-45
4 different versions of Solidity are used:
	- Version constraint ^0.8.26 is used by:
		-[^0.8.26](contracts/AlienzoneWearablesV2.3.sol#L2)
	- Version constraint ^0.8.20 is used by:
		-[^0.8.20](node_modules/@openzeppelin/contracts/access/Ownable.sol#L4)
		-[^0.8.20](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L4)
		-[^0.8.20](node_modules/@openzeppelin/contracts/utils/Context.sol#L4)
		-[^0.8.20](node_modules/@openzeppelin/contracts/utils/Panic.sol#L4)
		-[^0.8.20](node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol#L4)
		-[^0.8.20](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L5)
		-[^0.8.20](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L4)
		-[^0.8.20](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L4)
		-[^0.8.20](node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#L5)
	- Version constraint >=0.6.2 is used by:
		-[>=0.6.2](node_modules/@openzeppelin/contracts/interfaces/IERC1363.sol#L4)
	- Version constraint >=0.4.16 is used by:
		-[>=0.4.16](node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#L4)
		-[>=0.4.16](node_modules/@openzeppelin/contracts/interfaces/IERC20.sol#L4)
		-[>=0.4.16](node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#L4)
		-[>=0.4.16](node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#L4)
contracts/AlienzoneWearablesV2.3.sol analyzed (13 contracts with 101 detectors), 62 result(s) found

contracts/AlienzoneWearablesV2.3.sol#L2


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-46
[Context._contextSuffixLength()](node_modules/@openzeppelin/contracts/utils/Context.sol#L25-L27) is never used and should be removed

node_modules/@openzeppelin/contracts/utils/Context.sol#L25-L27


 - [ ] ID-47
[Context._msgData()](node_modules/@openzeppelin/contracts/utils/Context.sol#L21-L23) is never used and should be removed

node_modules/@openzeppelin/contracts/utils/Context.sol#L21-L23


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-48
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- [^0.8.20](node_modules/@openzeppelin/contracts/access/Ownable.sol#L4)
	- [^0.8.20](node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol#L4)
	- [^0.8.20](node_modules/@openzeppelin/contracts/utils/Context.sol#L4)
	- [^0.8.20](node_modules/@openzeppelin/contracts/utils/Panic.sol#L4)
	- [^0.8.20](node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol#L4)
	- [^0.8.20](node_modules/@openzeppelin/contracts/utils/StorageSlot.sol#L5)
	- [^0.8.20](node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol#L4)
	- [^0.8.20](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L4)
	- [^0.8.20](node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol#L5)

node_modules/@openzeppelin/contracts/access/Ownable.sol#L4


 - [ ] ID-49
Version constraint >=0.4.16 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- DirtyBytesArrayToStorage
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow
	- privateCanBeOverridden
	- SignedArrayStorageCopy
	- ABIEncoderV2StorageArrayWithMultiSlotElement
	- DynamicConstructorArgumentsClippedABIV2
	- UninitializedFunctionPointerInConstructor_0.4.x
	- IncorrectEventSignatureInLibraries_0.4.x
	- ExpExponentCleanup
	- NestedArrayFunctionCallDecoder
	- ZeroFunctionSelector.
It is used by:
	- [>=0.4.16](node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#L4)
	- [>=0.4.16](node_modules/@openzeppelin/contracts/interfaces/IERC20.sol#L4)
	- [>=0.4.16](node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#L4)
	- [>=0.4.16](node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol#L4)

node_modules/@openzeppelin/contracts/interfaces/IERC165.sol#L4


 - [ ] ID-50
Version constraint >=0.6.2 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- NestedCalldataArrayAbiReencodingSizeValidation
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- MissingEscapingInFormatting
	- ArraySliceDynamicallyEncodedBaseType
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow.
It is used by:
	- [>=0.6.2](node_modules/@openzeppelin/contracts/interfaces/IERC1363.sol#L4)

node_modules/@openzeppelin/contracts/interfaces/IERC1363.sol#L4


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-51
Parameter [AlienzoneWearables.setWearableOperator(address)._operator](contracts/AlienzoneWearablesV2.3.sol#L229) is not in mixedCase

contracts/AlienzoneWearablesV2.3.sol#L229


 - [ ] ID-52
Parameter [AlienzoneWearables.setProtocolFeeDestination(address)._feeDestination](contracts/AlienzoneWearablesV2.3.sol#L205) is not in mixedCase

contracts/AlienzoneWearablesV2.3.sol#L205


 - [ ] ID-53
Parameter [AlienzoneWearables.setZoneToken(address)._zoneToken](contracts/AlienzoneWearablesV2.3.sol#L199) is not in mixedCase

contracts/AlienzoneWearablesV2.3.sol#L199


 - [ ] ID-54
Parameter [AlienzoneWearables.setCreatorFeeBps(uint16)._feeBps](contracts/AlienzoneWearablesV2.3.sol#L217) is not in mixedCase

contracts/AlienzoneWearablesV2.3.sol#L217


 - [ ] ID-55
Parameter [AlienzoneWearables.setWearableSigner(address)._signer](contracts/AlienzoneWearablesV2.3.sol#L223) is not in mixedCase

contracts/AlienzoneWearablesV2.3.sol#L223


 - [ ] ID-56
Parameter [AlienzoneWearables.setProtocolFeeBps(uint16)._feeBps](contracts/AlienzoneWearablesV2.3.sol#L211) is not in mixedCase

contracts/AlienzoneWearablesV2.3.sol#L211


## too-many-digits
Impact: Informational
Confidence: Medium
 - [ ] ID-57
[Math.log2(uint256)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L619-L658) uses literals with too many digits:
	- [r = r | byte(uint256,uint256)(x >> r,0x0000010102020202030303030303030300000000000000000000000000000000)](node_modules/@openzeppelin/contracts/utils/math/Math.sol#L656)

node_modules/@openzeppelin/contracts/utils/math/Math.sol#L619-L658


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-58
Event [AlienzoneWearables.WearableOperatorUpdated(address)](contracts/AlienzoneWearablesV2.3.sol#L112) has address parameters but no indexed parameters

contracts/AlienzoneWearablesV2.3.sol#L112


 - [ ] ID-59
Event [AlienzoneWearables.WearableSignerUpdated(address)](contracts/AlienzoneWearablesV2.3.sol#L111) has address parameters but no indexed parameters

contracts/AlienzoneWearablesV2.3.sol#L111


 - [ ] ID-60
Event [AlienzoneWearables.ProtocolFeeDestinationUpdated(address)](contracts/AlienzoneWearablesV2.3.sol#L108) has address parameters but no indexed parameters

contracts/AlienzoneWearablesV2.3.sol#L108


 - [ ] ID-61
Event [AlienzoneWearables.ZoneTokenUpdated(address)](contracts/AlienzoneWearablesV2.3.sol#L113) has address parameters but no indexed parameters

contracts/AlienzoneWearablesV2.3.sol#L113


