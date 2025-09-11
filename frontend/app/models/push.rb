class Push
  include ActiveModel::Model

  attr_accessor :type, :email

  def push
    @user = User.find_by(email: email)
    messages[type].send_to @user
  end

  private

    def messages
      {
        'contest' => Push::ContestPlacement.new(ticket),
        'injury'  => Push::PlayerInjury.new(ticket.players.sample, ticket)
      }
    end

    def ticket
      @_ticket ||= @user.mlb_tickets.where(contest: Mlb::Contest.upcoming.pluck(:id)).sample
    end

end