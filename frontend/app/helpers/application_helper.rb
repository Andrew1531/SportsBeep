module ApplicationHelper

  MULTI_WORD_MASCOTS = [
    'Red Sox', 'White Sox', 'Blue Jays', 'Trail Blazers',
    'Blue Jackets', 'Maple Leafs', 'Red Wings', 'Red Bulls',
    'Timber Wolves', 'Thunder Cats'
  ].freeze

  def split_team_name(full_name)
    return ['', full_name || ''] if full_name.blank?
    MULTI_WORD_MASCOTS.each do |mascot|
      if full_name.end_with?(mascot)
        city = full_name[0...(full_name.length - mascot.length)].strip
        return [city, mascot]
      end
    end
    parts = full_name.split(' ')
    if parts.length > 1
      [parts[0...-1].join(' '), parts.last]
    else
      ['', full_name]
    end
  end

  def cache_key_for(relation, query = :all)
    count = relation.count
    max_updated_at = relation.maximum(:updated_at).try(:to_i)
    "#{relation.model}/#{query}-#{count}-#{max_updated_at}"
  end

  def timestamp(datetime)
    datetime.utc.iso8601
  end

  def est(datetime)
    datetime.in_time_zone('Eastern Time (US & Canada)')
  end

  def glyphicon(icon)
    content_tag(:span, '', class: "glyphicon glyphicon-#{icon}")
  end

  def create_or_update_text(record)
    (record.persisted?) ? 'Update' : 'Create'
  end

end
