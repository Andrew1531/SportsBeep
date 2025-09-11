class FinalizeContest

  attr_accessor :contest

  def initialize(contest)
    @contest = contest
    @contest.status = :finalized
  end

  def call
    tickets = order_tickets_by_score_in(contest)
    tickets.each_with_index do |ticket, n|
      ticket.update_column :placing, (n + 1)
    end
    contest.save!
    Background.push NotifyWinners, tickets.map(&:id)
  end

  private

    def order_tickets_by_score_in(contest)
      contest.tickets.sort_by(&:score).reverse
    end

end