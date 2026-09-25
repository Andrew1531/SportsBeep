class SportsDataSamplesController < ApplicationController
  before_action :authenticate_user!

  def index
    @snapshots = OpticOdds::MlbSnapshot.samples
    @fixtures = @snapshots.group_by { |snapshot| snapshot['fixture_id'] }
  end
end