class QuestionAnswer < ActiveRecord::Base
  belongs_to :question
  belongs_to :answer, class_name: 'Team'
  belongs_to :ticket

  validates :time, presence: true
  validates :ticket, presence: true
  validates :question, presence: true, uniqueness: { scope: :ticket, message: 'has already been answered' }

  def sum_for_chosen_team
    case answer
    when Nfl::Team
      ticket.game.team_stats.where(stat: question.topic.stat.id, team: answer).sum(:amount)
    else
      ticket.game.stats.where(stat: question.topic.stat.id, team: answer).sum(:amount)
    end
  end

  def sum_for_other_team
    case answer
    when Nfl::Team
      ticket.game.team_stats.where(stat: question.topic.stat.id).where.not(team: answer).sum(:amount)
    else
      ticket.game.stats.where(stat: question.topic.stat.id).where.not(team: answer).sum(:amount)
    end
  end

  def score
    if correct?
      (time / 14) * 2.8
    else
      0
    end
  end

  def correct?
    return false if question.nil?
    sum_for_chosen_team.send question.comparison_operator, sum_for_other_team
  end

  def incorrect?
    !correct?
  end

end
