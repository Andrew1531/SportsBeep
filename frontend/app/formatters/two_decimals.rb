class TwoDecimals

  def format(value)
    value ||= 0
    sprintf("%.2f", value)
  end

end