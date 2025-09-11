class ThreeDecimalsNoLeadingZero

  def format(value)
    value ||= 0
    output = sprintf("%.3f", value)
    output.slice! 0 if output[0] == '0'
    output
  end

end