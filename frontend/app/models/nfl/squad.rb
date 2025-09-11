class Nfl::Squad

  attr_accessor :stats

  def initialize(ticket)
    @stats = ticket.game.stats.where team: ticket.ticket_squads.find_by(position: name).team
  end

  def to_a
    stats.group_by(&:stat).map do |statdata, stats|
      {
        name: statdata.name,
        abbr: statdata.abbr,
        points_per: statdata.multiplier(NullPlayer.new(name)),
        amount: TwoDecimalsMaximumRounded.new.format(stats.map(&:amount).sum),
        points: TwoDecimalsMaximumRounded.new.format(stats.map(&:points).sum)
      }
    end
  end

  def score
    stats.total
  end

end