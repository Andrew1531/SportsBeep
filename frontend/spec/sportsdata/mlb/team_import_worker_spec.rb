describe Mlb::TeamImportWorker, sportsdata: true do
  let(:count) { 32 }
  let(:model) { Mlb::Team }
  let(:url) { %r[sportsdatallc.org/(.*)/teams/(.*).xml] }

  it_behaves_like 'a team importer'

end