Questions:
-[Done] I need to double check `amendSellOrder` Func handling of token amounts with test cases.
- [Done] I need to double check `buyOrder` Func validation of seller == msg.sender cant buy their own order.

Findings:
- (Potential): CEI Pattern not being followed correctly in `createSellOrder` Func.
- (Potential): CEI Pattern not being followed correctly in `amendSellOrder` Func.
- (Potential): Missing check for msg.sender can buy own order in `buyOrder` Func.
- (Potential): order.id == 0 should be the proper check even though order.seller == address(0) works fine.
- (Potential) Fee Calculation Precision with integer division, small orders might result in zero fees due to rounding down in `buyOrder` Func.
- (Potential) CEI Pattern not being followed correctly in `buyOrder` Func.