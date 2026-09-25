class ContestTemplateQuestion < ActiveRecord::Base
  before_save { SportsbookOnly.reject! }
  before_destroy { SportsbookOnly.reject! }
  belongs_to :contest_template
  belongs_to :question
end
