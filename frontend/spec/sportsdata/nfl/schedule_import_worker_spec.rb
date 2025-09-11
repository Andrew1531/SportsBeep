describe Nfl::ScheduleImportWorker, sportsdata: true do
  let(:model) { Nfl::Game }
  let(:url) { %r[sportsdatallc.org/(.*)/REG/schedule.json] }

  before do
    Nfl::TeamImportWorker.new.perform
  end

  it 'assigns a week to each game' do
    subject.perform
    Nfl::Game.all.each do |game|
      game.week.should be_between(1, 17)
    end
  end

  it_behaves_like 'a schedule importer'

end