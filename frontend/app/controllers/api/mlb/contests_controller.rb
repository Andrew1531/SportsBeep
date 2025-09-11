class Api::Mlb::ContestsController < Api::ContestsController

  private

    def contests
      current_user.mlb_contests
    end

end
