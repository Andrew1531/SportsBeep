module ApplicationHelper

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
