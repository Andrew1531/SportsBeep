module Mobile::PagesHelper

  def batter
    NullPlayer.new(pitcher: false)
  end

  def pitcher
    NullPlayer.new(pitcher: true)
  end

end
