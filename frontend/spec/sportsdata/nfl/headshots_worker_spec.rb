describe Nfl::HeadshotsWorker, sport: 'Nfl', sportsdata: true do

  before do
    Nfl::TeamImportWorker.new.perform
    Nfl::RosterImportWorker.new.perform
  end

  it 'queues up separate workers to download the images' do
    subject.perform
    Nfl::HeadshotsWorker::DownloadHeadshotWorker.jobs.size.should == 3
    Nfl::HeadshotsWorker::DownloadHeadshotWorker.drain
    WebMock.should have_requested(:get, %r[api.sportsdatallc.org/nfl-images-p2/usat/players/headshots/(.*).jpg]).times(3)
    Player.where.not(headshot: nil).size.should == 3
  end

end