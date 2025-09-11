describe Mlb::RosterImportWorker, sportsdata: true, sport: 'Mlb' do
  let(:count) { 749 }
  let(:url) { %r[sportsdatallc.org/(.*)/rosters/(.*).xml] }
  let(:model) { Mlb::Player }

  it_behaves_like 'a roster importer'

  it 'assigns the player to their teams' do
    Mlb::TeamImportWorker.new.perform
    subject.perform
    Mlb::Player.find_by(first_name: 'Drew',  last_name: 'Butera').team.name.should == 'Dodgers'
    Mlb::Player.find_by(first_name: 'Ramon', last_name: 'Santiago').team.name.should == 'Reds'
    Mlb::Player.all.each do |p|
      p.on_current_roster.should == true
    end
  end

  it 'removes players from the current roster if they arent in the XML' do
    inactive = Fabricate :player, on_current_roster: true
    Mlb::TeamImportWorker.new.perform
    subject.perform
    inactive.reload.on_current_roster.should == false
  end

  it 'sends push messages to users if a player is injured' do
    subject.perform
    ticket = Fabricate :ticket
    player = Mlb::Player.find_by external_id: 'f7deada3-d11e-490e-8658-ae83b7612014'
    ticket.players -= [ticket.players.last]
    ticket.players << player

    stubs = Rails.root.join 'spec', 'support', 'xml', 'mlb', 'roster-with-injury.xml'
    stub_request(:get, %r[api.sportsdatallc.org/mlb-p4/rosters/(.*).xml]).to_return body: File.new(stubs)

    subject.perform
    Push::Messenger.drain
    WebMock.should have_requested(:post, %r[gcm/send]).with(body: \
      "{\"registration_ids\":[\"#{ticket.user.device_token}\"],\"data\":{\"type\":\"injury\",\"player\":{\"id\":#{player.id},\"name\":\"#{player.name}\"},\"ticket\":#{ticket.id},\"game\":#{ticket.game.id},\"sport\":\"mlb\"},\"collapse_key\":null,\"time_to_live\":null,\"delay_while_idle\":null}")

  end

end