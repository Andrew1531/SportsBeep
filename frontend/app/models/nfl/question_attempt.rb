class Nfl::QuestionAttempt < ActiveRecord::Base
  before_save { SportsbookOnly.reject! }
  before_destroy { SportsbookOnly.reject! }
  self.table_name = 'nfl_question_attempts'

  belongs_to :ticket, class_name: 'Nfl::Ticket'
  belongs_to :question, class_name: 'Question'

  validates :started_at, presence: true
  validates :question_id, uniqueness: { scope: :ticket_id }
end