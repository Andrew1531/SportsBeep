class NullStat
  def self.before_save; end

  include ActiveModel::Model
  include Scoreable
  include Formattable

  attr_accessor :name, :amount, :points, :player
  attr_writer :stat

  def ==(other)
    [stat.id, amount, points, player] == [other.stat.id, other.amount, other.points, other.player]
  end

  def amount; 0; end
  def points; 0; end
  def updated_at; 20.years.ago; end

  def cache_key
    "#{Time.current.to_i}-#{SecureRandom.hex}"
  end

  def stat
    StatData.find @stat
  end

end