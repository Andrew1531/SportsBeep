describe Nfl::SeasonalStatsWorker, sportsdata: true, sport: 'Nfl' do

  let!(:game) { Fabricate :game }

  before do
    Nfl::TeamImportWorker.new.perform
    Nfl::RosterImportWorker.new.perform
  end

  it 'queues up one TeamSeasonalStatWorker per team' do
    subject.perform
    Nfl::SeasonalStatsWorker::TeamSeasonalStatWorker.jobs.size.should == Nfl::Team.count
  end

end