require './globals.rb'
require './serial_number.rb'
require './transaction_type.rb'
require './ticket.rb'

class Contest

  attr_reader :serial_number
  attr_reader :ticket_count
  attr_reader :tickets
  attr_reader :contest_entry_fee
  attr_reader :agent_commission_pool

  def initialize(contest_entry_fee)
    @serial_number = SerialNumber.nextSerialNumber
    @ticket_count = 0
    @tickets = Array.new
    @contest_entry_fee = contest_entry_fee
    @agent_commission_pool = 0
  end

  def self.join_contest(all_contests, gamer, contest_entry_fee)
    contest_to_join = nil
    all_contests.each do |this_contest|
      if this_contest.ticket_count < 10 && this_contest.contest_entry_fee == contest_entry_fee
        contest_to_join = this_contest
        break
      end
    end

    if contest_to_join == nil
      contest_to_join = Contest.new(contest_entry_fee)
      all_contests.push contest_to_join
    end

    contest_to_join.add_ticket(Ticket.new(gamer))

    gamer.transact_account contest_entry_fee, TransactionType::ContestEntryFee, "Fee: Contest #{contest_to_join.serial_number}"
    gamer.last_contest = $current_round

    contest_to_join
  end

  def add_ticket(ticket)
    @ticket_count += 1
    @tickets.push(ticket)
  end

  def cancel_contest
    if @ticket_count > 0
      @tickets.each do |t|
        t.gamer.transact_account @contest_entry_fee * -1, TransactionType::ContestEntryFee, "Fee Refund: Contest #{@serial_number}"
        t.gamer.last_contest = 0
      end
      @tickets = Array.new
      @ticket_count = 0
    end
  end

  def rank_contest
    # scoring goes here
    @tickets.sort! { |_| rand(3) - 1 }
  end

  def settle_contest
    if @ticket_count == 10

      credit_clearing_expense_r = @contest_entry_fee * 10 * $credit_clearing_expense_rate

      if $e_credit_clearing_expense >= credit_clearing_expense_r
        # /LS/ If the overall credit clearing expense account is over the expense for this game, we need
        # to move the whole expense for this game from that account to the contra-expense account (_r)

        $e_credit_clearing_expense -= credit_clearing_expense_r
        $e_credit_clearing_expense_r += credit_clearing_expense_r

      else
        # /LS/ Otherwise, we will be able to zero the overall credit clearing expense account but will have
        # some (or all) of this game's expense hold back left.  This happens when the "on deposit" expense
        # (actual) is overtaken by the "per game" expense hold back, which will happen.  If gamer X deposits
        # A dollars and plays and loses until they are zero, the expense we paid on the way in for A == the
        # expense they paid for the total of the games they played (e.g. $110 in == 10x$11 games).  On the other
        # hand, if they win, they could play 20 games on that same deposit (e.g. $110 in < 20x$11 games).

        # /LS/ Lower the expense for this game by whatever is left in credit clearing.  Expense is going to zero (final
        # step), but the amount over and above we're holding back will need to be recognized as income (next step).
        # Therefore, the amount held back minus the final balance in clearing expense is what will be income.
        # Note that only *rarely* will this be != the whole hold back.  For the *vast* majority of games, we're
        # either going to be moving from expense to contra-expense (the "if" part) or we're completely recouped and
        # recognizing this game's hold back in its entirety as income, in which case the following line will be -= 0.
        # It's only when we're crossing that line from one to the other that it will be a split transaction.

        credit_clearing_expense_r -= $e_credit_clearing_expense

        # /LS/ What's left in the expense hold back for this game is actually now income, so make the adjustment
        # to recoup banked (also an income account).  So, income-to-income adjustment.  That's where the income
        # is coming from.  It's not expense moving around at this point.  It's hold back from the contest fees
        # that need to just be recognized through a different income account.

        $i_contest_fee_income -= credit_clearing_expense_r
        $i_credit_clearing_recoup_banked += credit_clearing_expense_r

        # /LS/ Make the final adjustment from clearing expense to recouped (expense-to-contra-expense).  Again, this will
        # most often be _r += 0 and setting something that's already 0 == 0.

        $e_credit_clearing_expense_r += $e_credit_clearing_expense
        $e_credit_clearing_expense = 0
      end

      # /LS/ Final note: that could also be an if-elsif-else-end block with the >, ==, and < cases being handled separately,
      # but I didn't see the need.

      contest_commission = (@contest_entry_fee - @contest_entry_fee / 1.1) * 10
      @agent_commission_pool = (contest_commission - @contest_entry_fee * 10 * $credit_clearing_expense_rate) * 0.49

      (0..9).each do |ticket_num|
        payout = @contest_entry_fee * 10 / 1.1 * $prizes[ticket_num]
        if payout > 0
          @tickets[ticket_num].gamer.transact_account payout, TransactionType::Prize, "Prize Awarded: #{rank_text(ticket_num + 1)} for Contest #{@serial_number}"
        end

        settle_commission @tickets[ticket_num].gamer, @tickets[ticket_num].gamer, 1

        if @tickets[ticket_num].gamer.promo_balance > 0
          promo_release_amount = @contest_entry_fee * $promo_release_rate
          if promo_release_amount > @tickets[ticket_num].gamer.promo_balance
            promo_release_amount = @tickets[ticket_num].gamer.promo_balance
          end

          @tickets[ticket_num].gamer.transact_account promo_release_amount, TransactionType::PromoRelease, "Releasing #{promo_release_amount} of Promotional Balance."
        end
      end

      $i_contest_fee_income -= (contest_commission - @contest_entry_fee * 10 * $credit_clearing_expense_rate) * 0.51
      $i_contest_fee_income_retained += (contest_commission - @contest_entry_fee * 10 * $credit_clearing_expense_rate) * 0.51

      if @agent_commission_pool > 0
        $i_contest_fee_income -= @agent_commission_pool
        $i_commission_forfeited += @agent_commission_pool
      end
    end
  end

  def rank_text(rank)

    if rank.to_s.end_with? '1'
      text_value = rank.to_s + 'st'
    elsif rank.to_s.end_with? '2'
      text_value = rank.to_s + 'nd'
    elsif rank.to_s.end_with? '3'
      text_value = rank.to_s + 'rd'
    else
      text_value = rank.to_s + 'th'
    end

    text_value
  end

  def settle_commission(original_gamer, through_gamer, level)
    if level <= 7 && through_gamer.parent != nil
      agent_commission = ((contest_entry_fee - contest_entry_fee / 1.1) - (contest_entry_fee * $credit_clearing_expense_rate)) * 0.07

      if original_gamer.serial_number == through_gamer.serial_number
        through_gamer.parent.transact_account agent_commission, TransactionType::Commission, "Commission for Contest #{serial_number} from Gamer #{original_gamer.name}"
        @agent_commission_pool -= agent_commission
        if through_gamer.parent.is_commission_eligible == false
          through_gamer.parent.transact_account -1 * agent_commission, TransactionType::Commission, "Commission INELIGIBLE for Contest #{serial_number} from Gamer #{original_gamer.name}"
          @agent_commission_pool += agent_commission
        end
      else
        through_gamer.parent.transact_account agent_commission, TransactionType::Commission, "Commission for Contest #{serial_number} from Gamer #{original_gamer.name} through Agent #{through_gamer.name} at Level #{level}"
        @agent_commission_pool -= agent_commission
        if through_gamer.parent.is_commission_eligible == false
          through_gamer.parent.transact_account -1 * agent_commission, TransactionType::Commission, "Commission INELIGIBLE for Contest #{serial_number} from Gamer #{original_gamer.name}"
          @agent_commission_pool += agent_commission
        end
      end

      settle_commission original_gamer, through_gamer.parent, level + 1
    end
  end
end
