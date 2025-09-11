class LeaguePick

  attr_accessor :team, :game

  def initialize(team, game)
    @team = team
    @game = game
  end

  def ==(other)
    [team, game] == [other.team, other.game]
  end

  def score
    raise 'Implement #score!'
  end

  def amount
    stats.sum(:amount)
  end

  def season_total_for
    raise 'Implement #season_total_for!'
  end

  def scorers
    players = Player.where(id: stats.pluck(:player_id))
    players.map do |p|
      LeaguePick::Scorer.new(p.id, season_total_for(p))
    end
  end

  class Scorer < Struct.new(:id, :season_total)
    def name
      Player.find(id).name
    end
  end

end