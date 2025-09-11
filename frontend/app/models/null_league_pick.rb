class NullLeaguePick < LeaguePick

  def initialize
  end

  def score
    0
  end

  def amount
    0
  end

  def season_total_for(*)
    0
  end

  def nil?
    true
  end

  private

    def stats
      Stat.none
    end

end