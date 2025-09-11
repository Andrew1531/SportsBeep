class ContestTemplateQuestion < ActiveRecord::Base
  belongs_to :contest_template
  belongs_to :question
end
