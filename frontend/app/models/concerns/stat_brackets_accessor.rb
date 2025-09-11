module StatBracketsAccessor

  def [](statdata)
    fetch(statdata).amount
  end

  def store(statdata, value, attributes = {})
    stat = find_or_initialize_by attributes.merge(stat: statdata.id)
    stat.update(amount: value.to_f)
  end

  def fetch(statdata)
    stat = if loaded?
      find { |s| s.stat && s.stat.id == statdata.id }
    else
      find_by(stat: statdata.id)
    end
    player = proxy_association.owner
    stat || NullStat.new(stat: statdata.id, player: player)
  end

end