class UpdateBestAndBustTypeColumns < ActiveRecord::Migration[4.2]
  class Mlb::BestQuestion < BestQuestion; end
  class Mlb::BustQuestion < BustQuestion; end

  def change
    if table_exists?(:questions) && Question.count > 0
      Question.all.each do |question|
        question.type = question.type.gsub 'Mlb::', ''
        question.save
      end
    end
  end
end
