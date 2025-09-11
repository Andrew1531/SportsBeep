describe 'api/players/show.json.v2.jbuilder' do
  include_context 'authenticated', :user
  let(:player) { Fabricate :player, team: Fabricate(:team) }
  let(:ticket) { Fabricate :ticket }

  before do
    assign(:player, player)
  end

  it 'renders the player attributes' do
    render
    json.should include :id, :name, :number, :headshot_url, :position, :team
    json[:id].should == player.id
    json[:name].should == player.name
    json[:number].should == player.number
    json[:position].should == player.position
    json[:team][:id].should == player.team.id
  end

  it 'busts cache whenever the player is updated' do
    -> { player.update(number: 500) }.should bust_view_cache
  end

  it 'busts cache whenever summary stats are updated' do
    stat = Mlb::STATS_TO_DISPLAY_UNDER_NAME.(player).sample
    -> { Fabricate :recent_stat, player: player, stat: stat.stat.id }.should bust_view_cache
  end

  describe 'when ticket is present' do
    before do
      ticket.players = ticket.players.take(5)
      ticket.players << player
      assign(:ticket, ticket)
    end

    it 'renders the game position and score' do
      TicketPlayer.find_by(ticket: ticket, player: player).update(position: 'TEST')
      render
      json[:game_position].should == 'TEST'
      json[:score].should == '0.0'
    end

    it 'busts cache when the player changes game position' do
      proc do
        TicketPlayer.find_by(ticket: ticket, player: player).update! position: 'TEST'
        player.reload
      end.should bust_view_cache
    end
  end

  context 'Mlb', sport: 'Mlb' do
    before do
      Fabricate :recent_stat, name: :win,  amount: 1, player: player
      Fabricate :recent_stat, name: :loss, amount: 2, player: player
      Fabricate :recent_stat, name: :era,  amount: 0.250, player: player
      Fabricate :recent_stat, name: :k,    amount: 3, player: player
      Fabricate :recent_stat, name: :bb,   amount: 4, player: player
      Fabricate :recent_stat, name: :save, amount: 5, player: player
      Fabricate :recent_stat, name: :ab,   amount: 6, player: player
      Fabricate :recent_stat, name: :avg,  amount: 0.333, player: player
      Fabricate :recent_stat, name: :hr,   amount: 7, player: player
      Fabricate :recent_stat, name: :rbi,  amount: 8, player: player
      Fabricate :recent_stat, name: :bb,   amount: 9, player: player
    end

    describe 'starting pitcher' do
      let(:player) { Fabricate :player, position: 'SP', team: Fabricate(:team) }
      it 'displays win, loss, era, k, and bb for starting or closing pitcher' do
        render
        json[:stats].map { |stat| stat[:abbr] }.should =~ %w(WIN LOSS ERA K BB)
      end
    end

    describe 'relief pitcher' do
      let(:player) { Fabricate :player, position: 'RP', team: Fabricate(:team) }
      it 'displays win, save, era, k, and bb for relief pitcher' do
        render
        json[:stats].map { |stat| stat[:abbr] }.should =~ %w(WIN SAVE ERA K BB)
      end
    end

    describe 'anyone else' do
      let(:player) { Fabricate :player, position: '1B', team: Fabricate(:team) }
      it 'displays ab, avg, hr, rbi, and bb for non-pitchers' do
        render
        json[:stats].map { |stat| stat[:abbr] }.should =~ %w(AB AVG HR RBI BB)
      end
    end

    describe 'when player has a lineup position' do
      let(:player) { Fabricate :player, position: '1B', team: Fabricate(:team) }
      before do
        assign(:game, ticket.game)
        Fabricate :lineup_position, player: player, game: ticket.game, position: 2
      end

      it 'displays the lineup position over the official position' do
        render
        json[:position].should == 'C'
      end
    end
  end
end