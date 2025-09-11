class StatData
  include ActiveModel::Model

  attr_accessor :id, :abbr, :name, :sport

  def multiplier(player)
    case sport.name
    when 'Mlb'
      Mlb::ScoringMap.new.fetch(self, player)
    when 'Nfl'
      Nfl::ScoringMap.new.fetch(self, player)
    end
  end

  def self.find(id)
    id = id.to_i
    fetch_statdata(Mlb::Stats, Nfl::Stats).find do |statdata|
      statdata.id == id
    end
  end

  def to_i
    id
  end

  private

    def self.fetch_statdata(*namespaces)
      namespaces.map do |ns|
        ns.constants.map(&ns.method(:const_get))
      end.flatten
    end

end