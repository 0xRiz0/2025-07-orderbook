INFO:Detectors:
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) has bitwise-xor operator ^ instead of the exponentiation operator **: 
         - inverse = (3 * denominator) ^ 2 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#257)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-exponentiation
INFO:Detectors:
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#242)
        - inverse = (3 * denominator) ^ 2 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#257)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#242)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#261)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#242)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#262)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#242)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#263)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#242)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#264)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#242)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#265)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#242)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#266)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) performs a multiplication on the result of a division:
        - low = low / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#245)
        - result = low * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#272)
Math.invMod(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#315-361) performs a multiplication on the result of a division:
        - quotient = gcd / remainder (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#337)
        - (gcd,remainder) = (remainder,gcd - remainder * quotient) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#339-346)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply
INFO:Detectors:
OrderBook.getOrderDetailsString(uint256).tokenSymbol (src/OrderBook.sol#224) is a local variable never initialized
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#uninitialized-local-variables
INFO:Detectors:
OrderBook.constructor(address,address,address,address,address)._owner (src/OrderBook.sol#85) shadows:
        - Ownable._owner (lib/openzeppelin-contracts/contracts/access/Ownable.sol#21) (state variable)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing
INFO:Detectors:
OrderBook.amendSellOrder(uint256,uint256,uint256,uint256) (src/OrderBook.sol#138-175) uses timestamp for comparisons
        Dangerous comparisons:
        - block.timestamp >= order.deadlineTimestamp (src/OrderBook.sol#150)
OrderBook.buyOrder(uint256) (src/OrderBook.sol#194-213) uses timestamp for comparisons
        Dangerous comparisons:
        - block.timestamp >= order.deadlineTimestamp (src/OrderBook.sol#200)
OrderBook.getOrder(uint256) (src/OrderBook.sol#215-218) uses timestamp for comparisons
        Dangerous comparisons:
        - orders[_orderId].seller == address(0) (src/OrderBook.sol#216)
OrderBook.getOrderDetailsString(uint256) (src/OrderBook.sol#220-269) uses timestamp for comparisons
        Dangerous comparisons:
        - order.isActive && block.timestamp >= order.deadlineTimestamp (src/OrderBook.sol#236)
        - block.timestamp < order.deadlineTimestamp (src/OrderBook.sol#233-235)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
INFO:Detectors:
SafeERC20._callOptionalReturn(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#173-191) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#176-186)
SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#201-211) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#205-209)
Panic.panic(uint256) (lib/openzeppelin-contracts/contracts/utils/Panic.sol#50-56) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Panic.sol#51-55)
Strings.toString(uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#45-63) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#50-52)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#55-57)
Strings.toChecksumHexString(address) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#111-129) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#116-118)
Strings.escapeJSON(string) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#446-476) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#470-473)
Strings._unsafeReadBytesOffset(bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#484-489) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#486-488)
Math.add512(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#25-30) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#26-29)
Math.mul512(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#37-46) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#41-45)
Math.tryMul(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#73-84) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#76-80)
Math.tryDiv(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#89-97) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#92-95)
Math.tryMod(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#102-110) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#105-108)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#204-275) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#227-234)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#240-249)
Math.tryModExp(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#409-433) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#411-432)
Math.tryModExp(bytes,bytes,bytes) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#449-471) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#461-470)
Math.log2(uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#612-651) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#648-650)
SafeCast.toUint(bool) (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#1157-1161) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#1158-1160)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage
INFO:Detectors:
2 different versions of Solidity are used:
        - Version constraint ^0.8.20 is used by:
                -^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Panic.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#5)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4)
        - Version constraint ^0.8.0 is used by:
                -^0.8.0 (src/OrderBook.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used
INFO:Detectors:
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
        - VerbatimInvalidDeduplication
        - FullInlinerNonExpressionSplitArgumentEvaluationOrder
        - MissingSideEffectsOnSelectorAccess.
It is used by:
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Panic.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#5)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4)
Version constraint ^0.8.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
        - FullInlinerNonExpressionSplitArgumentEvaluationOrder
        - MissingSideEffectsOnSelectorAccess
        - AbiReencodingHeadOverflowWithStaticArrayCleanup
        - DirtyBytesArrayToStorage
        - DataLocationChangeInInternalOverride
        - NestedCalldataArrayAbiReencodingSizeValidation
        - SignedImmutables
        - ABIDecodeTwoDimensionalArrayMemory
        - KeccakCaching.
It is used by:
        - ^0.8.0 (src/OrderBook.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Parameter OrderBook.createSellOrder(address,uint256,uint256,uint256)._tokenToSell (src/OrderBook.sol#108) is not in mixedCase
Parameter OrderBook.createSellOrder(address,uint256,uint256,uint256)._amountToSell (src/OrderBook.sol#109) is not in mixedCase
Parameter OrderBook.createSellOrder(address,uint256,uint256,uint256)._priceInUSDC (src/OrderBook.sol#110) is not in mixedCase
Parameter OrderBook.createSellOrder(address,uint256,uint256,uint256)._deadlineDuration (src/OrderBook.sol#111) is not in mixedCase
Parameter OrderBook.amendSellOrder(uint256,uint256,uint256,uint256)._orderId (src/OrderBook.sol#139) is not in mixedCase
Parameter OrderBook.amendSellOrder(uint256,uint256,uint256,uint256)._newAmountToSell (src/OrderBook.sol#140) is not in mixedCase
Parameter OrderBook.amendSellOrder(uint256,uint256,uint256,uint256)._newPriceInUSDC (src/OrderBook.sol#141) is not in mixedCase
Parameter OrderBook.amendSellOrder(uint256,uint256,uint256,uint256)._newDeadlineDuration (src/OrderBook.sol#142) is not in mixedCase
Parameter OrderBook.cancelSellOrder(uint256)._orderId (src/OrderBook.sol#177) is not in mixedCase
Parameter OrderBook.buyOrder(uint256)._orderId (src/OrderBook.sol#194) is not in mixedCase
Parameter OrderBook.getOrder(uint256)._orderId (src/OrderBook.sol#215) is not in mixedCase
Parameter OrderBook.getOrderDetailsString(uint256)._orderId (src/OrderBook.sol#220) is not in mixedCase
Parameter OrderBook.setAllowedSellToken(address,bool)._token (src/OrderBook.sol#271) is not in mixedCase
Parameter OrderBook.setAllowedSellToken(address,bool)._isAllowed (src/OrderBook.sol#271) is not in mixedCase
Parameter OrderBook.emergencyWithdrawERC20(address,uint256,address)._tokenAddress (src/OrderBook.sol#278) is not in mixedCase
Parameter OrderBook.emergencyWithdrawERC20(address,uint256,address)._amount (src/OrderBook.sol#278) is not in mixedCase
Parameter OrderBook.emergencyWithdrawERC20(address,uint256,address)._to (src/OrderBook.sol#278) is not in mixedCase
Parameter OrderBook.withdrawFees(address)._to (src/OrderBook.sol#294) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
INFO:Detectors:
Math.log2(uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#612-651) uses literals with too many digits:
        - r = r | byte(uint256,uint256)(x >> r,0x0000010102020202030303030303030300000000000000000000000000000000) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#649)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#too-many-digits
INFO:Slither:. analyzed (12 contracts with 100 detectors), 55 result(s) found