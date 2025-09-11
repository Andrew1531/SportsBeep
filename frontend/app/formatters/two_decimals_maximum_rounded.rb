class TwoDecimalsMaximumRounded

  def format(value)
    value ||= 0
    return '0' if value.zero?
    f = sprintf("%.2e", value).to_f
    i = value.to_i
    str = (i == f ? i : f).to_s
    str.slice! 0 if f < 1 && str[0] == '0'
    str
  end

end