class ContestTemplate < ActiveRecord::Base
  belongs_to :game
  belongs_to :pool

  has_many :contests, foreign_key: :template_id, dependent: :destroy
  has_many :contest_template_questions, dependent: :destroy
  has_many :questions, through: :contest_template_questions
  has_many :best_questions, -> { where(type: 'BestQuestion') }, through: :contest_template_questions, source: :question, class_name: 'Question'
  has_many :bust_questions, -> { where(type: 'BustQuestion') }, through: :contest_template_questions, source: :question, class_name: 'Question'

  validate :must_have_3_bust_questions_and_3_best_questions, unless: :skip_question_validation?
  attr_accessor :skip_question_validation

  def skip_question_validation?
    skip_question_validation == true
  end

  # TODO: restricted join list

  private

    def must_have_3_bust_questions_and_3_best_questions
      if bust_questions.size != 3 || best_questions.size != 3
        errors.add(:questions, 'must contain 3 bust questions and 3 best questions')
      end
    end

end
