require './globals.rb'
require './transaction_type.rb'
require './transaction.rb'

class Gamer
  attr_reader :serial_number
  attr_accessor :is_agent
  attr_accessor :is_commission_eligible
  attr_accessor :name
  attr_accessor :parent
  attr_reader :children
  attr_accessor :last_contest
  attr_reader :transactions
  attr_reader :balance
  attr_reader :clearing_expense
  attr_accessor :promo_balance

  def initialize
    @serial_number = SerialNumber.nextSerialNumber
    @is_agent = false
    @is_commission_eligible = false
    @name = ''
    @parent = nil
    @children = Array.new
    @last_contest = 0
    @transactions = Array.new
    @balance = 0.0
    @clearing_expense = 0.0
    @promo_balance = 0.0
  end

  def self.add_agent(parent, opening_balance, promo_balance)
    new_agent = Gamer.new
    new_agent.is_agent = true
    new_agent.parent = parent
    new_agent.name = new_agent.serial_number.to_s
    if parent != nil
      new_agent.name = parent.name + '/' + new_agent.name
      parent.children.push new_agent
    else
      $top_level_gamers.push new_agent
    end
    $all_gamers.push new_agent
    $agent_gamers.push new_agent

    new_agent.transact_account opening_balance, TransactionType::Deposit, 'Opening Balance'
    new_agent.promo_balance = promo_balance

    new_agent
  end

  def self.add_gamer(parent, opening_balance, promo_balance)
    new_gamer = Gamer.new
    new_gamer.is_agent = false
    new_gamer.parent = parent
    new_gamer.name = new_gamer.serial_number.to_s
    if parent != nil
      new_gamer.name = parent.name + '/' + new_gamer.name
      parent.children.push new_gamer
    else
      $top_level_gamers.push new_gamer
    end
    $all_gamers.push new_gamer
    $non_agent_gamers.push new_gamer

    new_gamer.transact_account opening_balance, TransactionType::Deposit, 'Opening Balance'
    new_gamer.promo_balance = promo_balance

    new_gamer
  end

  def self.update_commission_eligibility
    $agent_gamers.each do |this_agent|
      active_children = 0

      # agent counts as its own active child
      active_children = active_children + 1 if this_agent.last_contest == $current_round

      # count active children that are not agents themselves
      this_agent.children.each do |this_child|
        active_children = active_children + 1 if this_child.last_contest == $current_round && this_child.is_agent == false
      end

      if active_children >= 10
        this_agent.is_commission_eligible = true
      else
        this_agent.is_commission_eligible = false
#        puts "#{this_agent.name} ineligible #{active_children} < 10"
      end
    end
  end

  def transact_account(amount, type, description)
    amount = amount.round(3)
    new_transaction = Transaction.new
    new_transaction.amount = amount

    if type == TransactionType::Withdrawal || type == TransactionType::ContestEntryFee
      new_transaction.amount *= -1
    end
    new_transaction.type = type
    new_transaction.description = description

    @balance += new_transaction.amount
    @transactions.push new_transaction

    $all_transactions.push new_transaction

    case type
      when TransactionType::Commission
        $e_commission_expense += amount
        $l_gamer_accounts += amount

      when TransactionType::Deposit
        $a_cash += amount * (1 - $credit_clearing_expense_rate)
        $l_gamer_accounts += amount
        $e_credit_clearing_expense += amount * $credit_clearing_expense_rate
        @clearing_expense += amount * $credit_clearing_expense_rate

        $total_deposits += new_transaction.amount

      when TransactionType::ContestEntryFee
        $l_gamer_accounts -= amount
        $i_contest_fee_income += amount
        @clearing_expense -= amount * $credit_clearing_expense_rate if @clearing_expense > 0

      when TransactionType::Prize
        $e_prize_expense += amount
        $l_gamer_accounts += amount

      when TransactionType::Withdrawal

        # /LS/ You're correct.  This simulation was modified to eat the fees in both directions.
        # For withdrawal fees as the responsibility of the user, this is the line:
        #
        # adjusted_amount = amount / (1 + $credit_clearing_expense_rate)

        adjusted_amount = amount

        if @clearing_expense > 0

          clearing_adjustment = @clearing_expense

          if clearing_adjustment > amount * $credit_clearing_expense_rate
            clearing_adjustment = amount * $credit_clearing_expense_rate
          end

          if clearing_adjustment > 0
            @clearing_expense -= clearing_adjustment
            adjusted_amount -= clearing_adjustment

            transact_account -1 * clearing_adjustment, TransactionType::Adjustment, "Early withdrawal fee of #{clearing_adjustment}."

            $e_credit_clearing_expense -= clearing_adjustment
            $e_credit_clearing_expense_r += clearing_adjustment
            $i_credit_clearing_recoup_ew += clearing_adjustment
          end
        end

        $a_cash -= adjusted_amount
        $l_gamer_accounts -= adjusted_amount

        new_transaction.amount -= (adjusted_amount - amount)
        @balance -= (adjusted_amount - amount)

        $total_withdrawals -= new_transaction.amount

      when TransactionType::PromoRelease
        $l_gamer_accounts += amount
        $e_promo_released += amount
        @promo_balance -= amount

      when TransactionType::Adjustment
        $l_gamer_accounts += amount

      else
        $l_gamer_accounts += amount
        $a_cash -= amount
    end
  end
end
