class NullPlayer
  include ActiveModel::Model

  attr_accessor :type

  def initialize(type = :special)
    @type = type.to_s
  end

  def method_missing(method, *args)
    if method.to_s.ends_with? '?'
      @type == method.to_s.chop
    else
      super
    end
  end

end