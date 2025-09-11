class EnterContest

  attr_reader :ticket

  def initialize(ticket)
    @ticket = ticket
  end

  def call(game, pool)
    template = pool.contest_templates.find_by game: game
    if template.present?
      ticket.contest = template.contests.open.where.not(id: ticket.user.contests(sport).pluck(:id)).take || template.contests.create(type: "#{sport}::Contest")
      ContestEntryFeeTransaction.commit(ticket.user, pool.entry_fee)
      clone_errors_from_contest if ticket.contest.invalid?
    else
      ticket.errors.add(:base, 'No contests exist for the selected game & pool')
    end
  end

  def call!(game, pool)
    call game, pool
    ticket.save!
  end

  private

    def sport
      ticket.class.name[/(Mlb|Nfl)/]
    end

    def clone_errors_from_contest
      ticket.contest.errors.full_messages.each do |message|
        ticket.errors.add(:contests, message)
      end
    end

end