class Api::Nfl::ContestsController < Api::ContestsController

  private

    def contests
      current_user.nfl_contests
    end

end