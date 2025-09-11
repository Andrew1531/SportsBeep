Fabricator(:lineup_position) do
  game
  player
  position { rand(1..12) }

  after_build do |lp|
    # The casted's position= is overriden, so call that first
    # then re-assign position to the value from the setter
    casted = _sport(LineupPosition).new
    casted.position = lp.position
    lp.position = casted.position
  end

end
