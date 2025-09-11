class StatConfiguration

  def initialize(config)
    @config = config.with_indifferent_access
  end

  def [](name)
    OpenStruct.new @config[name]
  end

  def scored
    @config.select { |_, v| v && v.include?(:points) }.keys
  end

  # Returns all of the stat names that should be averaged by inspecting
  # the lastXgames field of the YAML configuration file
  def averaged
    @config.select { |_, v| v && v[:lastXgames] == 'average' }.keys
  end

  # Returns all of the stat names that should be summed. Because that is
  # the default behaviour, this just checks if lastXgames is excluded
  def summed
    @config.select { |_, v| v.nil? || v.exclude?(:lastXgames) }.keys
  end

  # Returns all of the stats that should appear on the "Expanded" screen
  # for a particular position
  def expanded(position)
    expanded = @config['expanded']
    expanded.fetch position, expanded['BP']
  end

end