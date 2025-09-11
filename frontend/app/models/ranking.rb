class Ranking
  include ActiveModel::Model
  attr_accessor :stat
  attr_reader :rank

  def name
    I18n.translate("league_pick_stats.#{stat.abbr.downcase.gsub(' ', '_')}")
  end

  def value
    stat.amount
  end

  def ==(other)
    stat == other.stat
  end

  # ranks the stat value among the stat collection given
  def rank!(collection)
    collection = collection.sort.reverse
    index = collection.index(value)
    @rank = index ? (index + 1) : 0
  end

end