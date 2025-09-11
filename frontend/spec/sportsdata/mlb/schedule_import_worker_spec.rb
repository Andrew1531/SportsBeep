describe Mlb::ScheduleImportWorker, sportsdata: true do
  let(:model) { Mlb::Game }
  let(:url) { %r[sportsdatallc.org/(.*)/schedule/(.*).xml] }

  before do
    Mlb::TeamImportWorker.new.perform
  end

  it_behaves_like 'a schedule importer'

  it 'does not include the all-star game' do
    subject.perform
    model.all.select { |g| g.home_team.name == 'American League' }.count.should == 0
  end

end