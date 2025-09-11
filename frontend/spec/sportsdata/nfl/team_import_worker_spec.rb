describe Nfl::TeamImportWorker, sportsdata: true do
  let(:count) { 32 }
  let(:model) { Nfl::Team }
  let(:url) { %r[sportsdatallc.org/(.*)/teams/hierarchy.json] }

  it_behaves_like 'a team importer'

end