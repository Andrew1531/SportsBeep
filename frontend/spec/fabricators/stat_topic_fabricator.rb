Fabricator(:stat_topic) do
  stat
  comparison { %w(more less).sample }
  type { ENV['SPORT'] && "#{ENV['SPORT']}::StatTopic" }
end