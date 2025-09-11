describe Mlb::HeadshotsWorker, sport: 'Mlb', sportsdata: true do

  before do
    Mlb::TeamImportWorker.new.perform
    Mlb::RosterImportWorker.new.perform
  end

  it 'queues up separate workers to download the images' do
    subject.perform
    Mlb::HeadshotsWorker::DownloadHeadshotWorker.jobs.size.should == 3
    Mlb::HeadshotsWorker::DownloadHeadshotWorker.drain
    WebMock.should have_requested(:get, %r[api.sportsdatallc.org/mlb-images-p2/usat/players/headshots/(.*).jpg]).times(3)
    Player.where.not(headshot: nil).size.should == 3
  end

end