# describe WithdrawalTransaction do
#   let(:user) { Fabricate :user }
#   it_behaves_like 'a transaction'

#   before { user.account.update balance: 100.00 }

#   context 'when clearing expense is greater than 0' do
#     before do
#       user.account.update clearing_expense: 2.45
#       WithdrawalTransaction.commit(user, 50.00)
#     end

#     it 'calculates a clearing adjustment based on the CC expense rate and subtracts it from the users clearing expense' do
#       p user.account.reload.balance.cents
#     end

#     it 'subtracts the clearing adjustment from the user for early withdrawal fee' do
#     end

#     it 'subtracts the clearing adjustment from the E Credit Clearing expense GL account' do
#     end

#     it 'adds the clearing adjustment to the E Credit Clearing expense R GL account' do
#     end

#     it 'adds the clearing adjustment to the I Credit Clearing Recoup Ew GL Account' do
#     end
#   end

#   context 'when clearing expense is <= 0' do
#     before { WithdrawalTransaction.commit(user, 50.00) }

#     it 'subtracts the amount from the A Cash GL account' do
#     end

#     it 'subtracts the amount from the L Gamer GL account' do
#     end

#     it 'sets the transaction amount to the adjustment amount - the amount' do
#     end

#     it 'subtracts the adjustment amount - the amount from the users balance' do
#     end
#   end

# end