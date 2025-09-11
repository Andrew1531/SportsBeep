class ContestTemplate
  attr_accessor :game
  attr_accessor :contest_rules
  attr_accessor :question_pool
  attr_accessor :restricted_join_list
  attr_accessor :maximum_contests
end

# normal => pool has 10 tickets, rjl is nil, maximum_contests is 0
# me and 9 friends => pool has 10 tickets, rjl has 10, maximum contests is 1 (defaults to rjl / pool tickets)
# 100 people in special pool => pool has 25 tickets, rjl has 100, maximum contests is 4 (defaults to rjl / pool tickets)
# 100 people in special pool, first come first serve => pool has 25 tickets, rjl has 100, maximum contests is 1
