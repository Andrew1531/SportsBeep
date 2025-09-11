module ActiveRecord
  class Base

    def self.cache_key
      relation = all.dup
      relation.includes_values = []
      Digest::MD5.hexdigest "#{relation.to_sql}-#{relation.maximum(:updated_at).try(:utc).try(:to_s, :nsec)}-#{relation.count}"
    end

  end
end