class Object

  def _sport(klass = nil)
    sport = (ENV['SPORT'] && ENV['SPORT'].constantize) || self.class.name[/(Mlb|Nfl)/].to_s.safe_constantize
    if klass
      sport.const_get(klass.try(:name) || klass)
    else
      sport
    end
  end

end