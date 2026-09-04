class TokenAmount
  class InvalidAmount < ArgumentError; end

  def self.parse(value, decimals:)
    text = value.to_s.strip
    match = /\A(\d+)(?:\.(\d+))?\z/.match(text)
    raise InvalidAmount, 'Enter a positive decimal amount.' unless match
    fraction = match[2].to_s
    raise InvalidAmount, "This token supports at most #{decimals} decimal places." if fraction.length > decimals.to_i
    units = match[1].to_i * (10 ** decimals.to_i) + fraction.ljust(decimals.to_i, '0').to_i
    raise InvalidAmount, 'Enter an amount greater than zero.' unless units.positive?
    units
  end

  def self.format(units, decimals:)
    units = units.to_i
    scale = 10 ** decimals.to_i
    return units.to_s if decimals.to_i.zero?
    whole, fraction = units.divmod(scale)
    "#{whole}.#{fraction.to_s.rjust(decimals.to_i, '0').sub(/0+\z/, '')}".sub(/\.\z/, '')
  end
end