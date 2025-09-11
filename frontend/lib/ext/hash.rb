class Hash

  def drill(key, default: 0)
    key.split('.').inject(self) { |memo, obj| memo[obj] if memo.is_a? Hash } || default
  end

end
