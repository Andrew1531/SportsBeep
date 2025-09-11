class Test
  class << self
    attr_accessor :ci
    alias new2 new
    def new(*arg)
      @ci = Array.new
      new2(*arg)
    end
  end
end

class Test2 < Test

end

Test2.ci.push 1
Test2.ci.push 2
puts Test2.ci
