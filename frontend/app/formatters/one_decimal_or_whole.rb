class OneDecimalOrWhole

  def format(value)
    value ||= 0
    sprintf("%g", value.round(1))
  end

end