module Formattable
  extend ActiveSupport::Concern

  def to_s
    stat.name
  end

  def abbr
    stat.abbr
  end

  def format(attribute)
    formatter.format send(attribute)
  end

  private

    def formatter
      case stat
      when Mlb::Stats::SLUGGING_PCT, Mlb::Stats::BATTING_AVERAGE, Mlb::Stats::ON_BASE_PCT, Mlb::Stats::ON_BASE_AVERAGE
        ThreeDecimalsNoLeadingZero.new
      when Mlb::Stats::ERA, Mlb::Stats::WHIP
        TwoDecimals.new
      else
        TwoDecimalsMaximumRounded.new
      end
    end

    def translate(key, options = {})
      I18n.t("stats.#{player._sport.to_s.downcase}.#{name}.#{key}", options)
    end

end