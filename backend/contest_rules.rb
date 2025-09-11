class ContestRules
  attr_accessor :maximum_tickets_per_contest
  attr_accessor :minimum_tickets_per_contest
  attr_accessor :entry_fee
  attr_accessor :entry_fee_multiple
  attr_accessor :prize_schedules
  attr_accessor :restricted_join_list
  attr_accessor :maximum_contests

  def initialize
    @maximum_tickets_per_contest = 10
    @minimum_tickets_per_contest = 10
    @entry_fee = 10
    @entry_fee_multiple = 1.1 # basically means there's a 10% premium to enter this pool
    @prize_schedules =
        [
            [0.21, 0.17, 0.15, 0.125, 0.12, 0.115, 0.11, 0, 0, 0 ]
        ]
    @restricted_join_list = []
    @maximum_contests = -1
  end
end
