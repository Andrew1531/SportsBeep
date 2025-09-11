class Nfl::Player < Player

  INJURED_STATUS = %w(D7 D15 D60 OFS)

  def quarterback?
    position.in? %w(QB)
  end

  def running_back?
    position.in? %w(RB TB FB HB WB)
  end

  def defense?
    position.in? %w(CB DB DE DT FS ILB LB MLB NT OLB SAF SS)
  end

  def kicker?
    position.in? %w(K PK)
  end

  def receiver?
    position.in? %w(WR TE)
  end

  def special_teams?
    position.in? %w(H KOS KR P PR)
  end

  def just_injured?
    result = status_changed?
    result &&= !status_was.in?(INJURED_STATUS)
    result &&= status.in?(INJURED_STATUS)
    result
  end

end
