describe Nfl::RosterImportWorker, sportsdata: true do
  let(:count) { 88 }
  let(:url) { %r[sportsdatallc.org/(.*)/teams/PIT/roster.json] }
  let(:model) { Nfl::Player }

  before { Nfl::TeamImportWorker.new.perform }

  it_behaves_like 'a roster importer'

  it 'assigns the player to their teams' do
    subject.perform
    Nfl::Player.all.each do |p|
      p.team.should be_present
    end
  end

end