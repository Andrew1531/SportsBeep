class HexValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless value =~ /^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i
      record.errors[attribute] << 'is not a valid hex value'
    end
  end

end