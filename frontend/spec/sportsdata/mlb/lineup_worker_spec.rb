describe Mlb::LineupWorker, sportsdata: true do
  let(:game) { Fabricate :game }

  before do
    Mlb::RosterImportWorker.new.perform
  end

  it 'creates a lineup player for each player in the lineup' do
    subject.perform(game.id)
    game.lineup_players.size.should == 21
  end

  it 'does not send a push if position and lineup position are the same' do
    player = Mlb::Player.find_by external_id: '04931bc2-76ee-4427-8da8-b5b3696f9ba6'
    subject.perform(game.id)
    player.position.should == player.position_in(game)
    WebMock.should_not have_requested(:post, %r[gcm/send])
  end

  # it 'sends a push if the lineup position differs from the official position' do
  #   ticket = Fabricate :ticket
  #   player = Mlb::Player.find_by external_id: 'b54ace79-5c94-45d1-873a-7ae90e5c6726'
  #   ticket.players -= [ticket.players.last]
  #   ticket.players << player
  #   subject.perform(game.id)
  #   Push::Messenger.drain
  #   WebMock.should have_requested(:post, %r[gcm/send]).with(body: \
  #      "{\"registration_ids\":[\"#{ticket.user.device_token}\"],\"data\":{\"type\":\"position_update\",\"player\":{\"id\":#{player.id},\"name\":\"#{player.name}\",\"position\":\"RF\"},\"ticket\":#{ticket.id},\"game\":#{ticket.game.id}},\"collapse_key\":null,\"time_to_live\":null,\"delay_while_idle\":null}")
  # end

end