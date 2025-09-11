# 10 retail
# play it and pay it
# recoup in total on withdrawal

require './globals.rb'
require './contest.rb'
require './gamer.rb'
require './serial_number.rb'
require './ticket.rb'
require './transaction.rb'
require './transaction_type.rb'

##########
##########     S I M U L A T I O N    P A R A M E T E R S
##########

# 1,680,000 yearly target

top_level_agents = 45000
sub_agents = 0
gamers = 0
levels = 1
opening_balance = 572 # 11 * 52
promotional_balance = 0
rounds = 53

participation_target = 1.0
attrition_target = 0
growth_target = 0

##########
##########
##########

def add_subs(parent, sub_agents, gamers, opening_balance, promo_balance, level)
  print "#{parent.name}\n"
  $stdout.flush

  if level > 0
    (1..gamers).each do
      Gamer.add_gamer(parent, opening_balance, promo_balance)
    end

    if level > 1
      (1..sub_agents).each do
        add_subs(Gamer.add_agent(parent, opening_balance, promo_balance), sub_agents, gamers, opening_balance, promo_balance, level - 1)
      end
    end
  end
end

def fmt(number, width: 20, commas: true, decimals: 2)
  fmt_out = number.round(decimals).to_s
  fmt_out += '.'.ljust(decimals + 1, '0') if decimals > 0 && fmt_out.index('.') == nil
  fmt_out += '0' while decimals > 0 && fmt_out.split(/\./)[1].length < decimals
  length_limit = 3
  decimal_adjust = decimals > 0 ? decimals + 1 : 0
  sign_adjust = fmt_out.start_with?('+') || fmt_out.start_with?('-') ? 1 : 0
  while commas && fmt_out.length > length_limit + decimal_adjust + sign_adjust
    fmt_out = fmt_out.insert 0 - length_limit - decimal_adjust - 1, ','
    length_limit += 4
  end
  fmt_out.rjust(width)
end

(1..top_level_agents).each do |_|
  add_subs(Gamer.add_agent(nil, opening_balance, promotional_balance), sub_agents, gamers, opening_balance, promotional_balance, levels)
end

total_contests = 0
total_contests_cancelled = 0

(1..rounds).each do |this_round|
  print "round #{this_round}\n"
  $stdout.flush

  $current_round = this_round

  $all_contests = Array.new

  participation_countdown = ($all_gamers.length * participation_target).to_i
  puts "    Participation for This Round: #{participation_countdown} out of #{$all_gamers.length} (based on #{participation_target})"
  $stdout.flush

  puts "    Randomizing Gamer List"
  $stdout.flush

  $all_gamers.sort! { |_| rand(3) - 1 }

  puts "    Joining Gamers to Contests"
  $stdout.flush

  $all_gamers.each do |this_gamer|
    if this_gamer.balance >= $contest_entry_fees.min && participation_countdown > 0
      participation_countdown = participation_countdown - 1

      $contest_entry_fees.sort! { |_| rand(3) - 1 }
      while this_gamer.balance < $contest_entry_fees[0]
        $contest_entry_fees.sort! { |_| rand(3) - 1 }
      end

      Contest.join_contest $all_contests, this_gamer, $contest_entry_fees[0]
    end
  end

  total_contests += $all_contests.length

  $all_contests.each do |this_contest|
    if this_contest.ticket_count != 10
      total_contests_cancelled += 1
      this_contest.cancel_contest
      puts "    Contest #{@serial_number} cancelled."
    end
  end

  Gamer.update_commission_eligibility

  agents_eligible = 0
  agents_ineligible = 0
  $all_gamers.each do |this_gamer|
    if this_gamer.is_agent
      if this_gamer.is_commission_eligible
        agents_eligible = agents_eligible + 1
      else
        agents_ineligible = agents_ineligible + 1
      end
    end
  end

  puts "        Agent Commission Status for This Round: #{agents_eligible} eligible, #{agents_ineligible} ineligible."
  $stdout.flush

  $all_contests.each do |this_contest|
    if this_contest.ticket_count == 10
      this_contest.rank_contest
      this_contest.settle_contest
    end
  end

  attrition_countdown = ($all_gamers.length * attrition_target).to_i
  puts "    Attrition for This Round: #{attrition_countdown} out of #{$all_gamers.length} (based on #{attrition_target})"
  $stdout.flush

  while attrition_countdown > 0
    attrition_countdown = attrition_countdown - 1

    gamer_index = rand($all_gamers.length)
    while $all_gamers[gamer_index].balance <= 0 || $all_gamers[gamer_index].is_agent
      gamer_index = rand($all_gamers.length)
    end

    $all_gamers[gamer_index].transact_account $all_gamers[gamer_index].balance, TransactionType::Withdrawal, 'Cash Out'

    $all_gamers.delete_at(gamer_index)
  end

  growth_countdown = ($all_gamers.length * growth_target).to_i
  puts "    Growth for This Round: #{growth_countdown} out of #{$all_gamers.length} (based on #{growth_target})"
  $stdout.flush

  while growth_countdown > 0
    growth_countdown = growth_countdown - 1

    gamer_index = rand($all_gamers.length)
    while !$all_gamers[gamer_index].is_agent
      gamer_index = rand($all_gamers.length)
    end

    Gamer.add_gamer($all_gamers[gamer_index], opening_balance, promotional_balance)
  end
end

winners = 0
winnings = 0
losers = 0
losses = 0

winning_gamers = Array.new

$all_gamers.sort! { |a,b| a.balance <=> b.balance }

$all_gamers.each do |this_gamer|
  puts "====== Gamer Name #{this_gamer.name} :: IS_AGENT #{this_gamer.is_agent}\n"
  puts "balance #{fmt(this_gamer.balance)}\n"

  if this_gamer.balance >= opening_balance
    winners += 1
    winnings += this_gamer.balance
    winning_gamers.push this_gamer
  else
    losers += 1
    losses += this_gamer.balance
  end

  this_gamer.transact_account this_gamer.balance, TransactionType::Withdrawal, 'Cash Out'

  this_gamer.transactions.each do |t|
    #total_deposits += t.amount if t.type == TransactionType::Deposit
    #total_withdrawals -= t.amount if t.type == TransactionType::Withdrawal

#    puts "#{fmt(t.serial_number, decimals: 0)} #{TransactionType.to_s(t.type).ljust(18)} #{fmt(t.amount)} #{t.description}\n"
  end
  puts "balance #{fmt(this_gamer.balance)}\n"
end

income = $i_contest_fee_income
income += $i_contest_fee_income_retained
income += $i_commission_forfeited
income += $i_credit_clearing_recoup_banked
income += $i_credit_clearing_recoup_ew

expenses = $e_credit_clearing_expense
expenses += $e_credit_clearing_expense_r
expenses += $e_prize_expense
expenses += $e_commission_expense
expenses += $e_promo_released

net_income = income - expenses

assets = $a_cash

liabilities_and_capital = $l_gamer_accounts + net_income

puts '-------------------------------------------------------------------------'

puts "Top Level Agents                 #{fmt(top_level_agents, decimals: 0)}"
puts "Levels                           #{fmt(levels, decimals: 0)}"
puts "Sub-Agents per Level             #{fmt(sub_agents, decimals: 0)}"
puts "Gamers                           #{fmt(gamers, decimals: 0)}"
puts "Opening Balance                  #{fmt(opening_balance, decimals: 0)}"
puts "Promo Balance                    #{fmt(promotional_balance, decimals: 0)}"
puts "Rounds                           #{fmt(rounds, decimals: 0)}"

puts '-------------------------------------------------------------------------'

puts "Elapsed Time                     #{fmt(0, decimals: 0)}"
puts "Total Gamers                     #{fmt($all_gamers.length, decimals: 0)}"
puts "Top-Level Gamers                 #{fmt($top_level_gamers.length, decimals: 0)}"
puts "Total Agents                     #{fmt($agent_gamers.length, decimals: 0)}"
puts "Total Non-Agents                 #{fmt($non_agent_gamers.length, decimals: 0)}"

puts '-------------------------------------------------------------------------'

puts "Total Contests                   #{fmt(total_contests, decimals: 0)}"
puts "Total Contests Cancelled         #{fmt(total_contests_cancelled, decimals: 0)}"

puts '-------------------------------------------------------------------------'

puts "Total Cash Positive Gamers       #{fmt(winners, decimals: 0)}"
puts "Total Cash Negative Gamers       #{fmt(losers, decimals: 0)}"
puts "Total Gamers                     #{fmt(winners + losers, decimals: 0)}"
puts "% Cash Positive Gamers           #{fmt(winners * 100 / (winners + losers), decimals: 0)}%"

puts '-------------------------------------------------------------------------'

puts "% Cash Positive (Average)        #{fmt(winnings * 100 / (winners * opening_balance) - 100, decimals: 0)}%"
puts "% Cash Negative (Average)        #{fmt(100 - losses * 100 / (losers * opening_balance), decimals: 0)}%"

puts '-------------------------------------------------------------------------'

puts "Deposits                         #{fmt($total_deposits)}"
puts "Credit Card Settling Fees        #{fmt($total_deposits * $credit_clearing_expense_rate)}"
puts "Withdrawals                      #{fmt($total_withdrawals)}"

puts '-------------------------------- --------------------'

puts "Deposits Retained                #{fmt($total_deposits * (1 - $credit_clearing_expense_rate) - $total_withdrawals)}"

puts '-------------------------------------------------------------------------'

puts "Cash                             #{fmt($a_cash)}"
puts "Player Account Liability         #{fmt($l_gamer_accounts, width: 40)}"
puts "Net Income                       #{fmt(net_income, width: 40)}"

puts '-------------------------------- -------------------- -------------------'

puts "Totals                           #{fmt(assets)}#{fmt(liabilities_and_capital)}"

puts '-------------------------------------------------------------------------'

puts "Contest Fee Revenue Expensed     #{fmt($i_contest_fee_income)}"
puts "Contest Fee Revenue Retained     #{fmt($i_contest_fee_income_retained)}"
puts "Contest Fee Commission Forfeited #{fmt($i_commission_forfeited)}"
puts "Credit Clearing Recoup Banked    #{fmt($i_credit_clearing_recoup_banked)}"
puts "Credit Clearing Recoup Early W.  #{fmt($i_credit_clearing_recoup_ew)}"
puts "Credit Clearing Expense          #{fmt($e_credit_clearing_expense, width: 40)}"
puts "Credit Clearing Expense Recouped #{fmt($e_credit_clearing_expense_r, width: 40)}"
puts "Prize Expense                    #{fmt($e_prize_expense, width: 40)}"
puts "Commission Expense               #{fmt($e_commission_expense, width: 40)}"
puts "Promotional Monies Released      #{fmt($e_promo_released, width: 40)}"

puts '-------------------------------- -------------------- -------------------'

puts "Totals                           #{fmt(income)}#{fmt(expenses)}"

puts '-------------------------------------------------------------------------'
