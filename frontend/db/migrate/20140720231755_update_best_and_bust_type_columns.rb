class UpdateBestAndBustTypeColumns < ActiveRecord::Migration[4.2]
  class Mlb::BestQuestion < BestQuestion; end
  class Mlb::BustQuestion < BustQuestion; end

  def change
    if table_exists?(:questions)
      execute "UPDATE questions SET type = REPLACE(type, 'Mlb::', '') WHERE type LIKE 'Mlb::%'" rescue nil
    end
  end
end
