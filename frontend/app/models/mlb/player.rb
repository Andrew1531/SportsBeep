class Mlb::Player < Player

  INJURED_STATUS = %w(D7 D15 D60 OFS)

  def pitcher?
    (position =~ /(CP|RP|SP)/i).present?
  end

  def just_injured?
    result = status_changed?
    result &&= !status_was.in?(INJURED_STATUS)
    result &&= status.in?(INJURED_STATUS)
    result
  end

end
