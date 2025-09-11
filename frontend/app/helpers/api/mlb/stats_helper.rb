module Api::Mlb::StatsHelper

  def st(key, sport = nil)
    sport = sport ? sport.to_s.downcase : _sport.to_s.downcase
    @translations ||= I18n.t("stats.#{sport}")
    @translations[key.intern].try(:[], :desc) || key.to_s
  end

  def round(float)
    float.round(2).to_s
  end

  def format_stat(amount, name = nil)
    amount ||= 0
    case name
    when /(slg|avg|obp|oba)/i
      avg = sprintf("%.3f", amount)
      avg.slice! 0 if avg[0] == '0'
      avg
    when /(era|whip)/i
      sprintf("%.2f", amount)
    else
      return '0' if amount.zero?
      f = sprintf("%.2e", amount).to_f
      i = amount.to_i
      str = (i == f ? i : f).to_s
      str.slice! 0 if f < 1 && str[0] == '0'
      str
    end
  end

  def stats_to_display_under(player)
    player._sport::STATS_TO_DISPLAY_UNDER_NAME.call(player)
  end

end
