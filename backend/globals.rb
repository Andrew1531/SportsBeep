# Jenkins
# Rspec

$all_transactions = Array.new

$total_deposits = 0
$total_withdrawals = 0

$a_cash = 0
$l_gamer_accounts = 0
$i_contest_fee_income = 0
$i_contest_fee_income_retained = 0
$i_commission_forfeited = 0
$i_credit_clearing_recoup_banked = 0
$i_credit_clearing_recoup_ew = 0
$e_credit_clearing_expense = 0
$e_credit_clearing_expense_r = 0
$e_prize_expense = 0
$e_commission_expense = 0
$e_promo_released = 0

$all_gamers = Array.new
$top_level_gamers = Array.new
$non_agent_gamers = Array.new
$agent_gamers = Array.new

$all_contests = Array.new
$prizes = [ 0.21, 0.17, 0.15, 0.125, 0.12, 0.115, 0.11, 0, 0, 0 ]

#$contest_entry_fees = [ 0, 2.20, 5.50, 11.00, 22.00, 55.00, 110.00, 275.00, 550.00 ]
$contest_entry_fees = [ 11.00 ]

$credit_clearing_expense_rate = 0.02

$promo_release_rate = 0.03

$current_round = 0
