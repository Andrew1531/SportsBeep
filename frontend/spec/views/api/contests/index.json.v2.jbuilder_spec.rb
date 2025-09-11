describe 'api/contests/index.json.v2.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user
  before { assign(:contests, contests) }
  before { assign(:tickets, user.tickets.where(contest: contests)) }

  context 'with multiple contests' do
    let(:contests) { Fabricate.times 5, :contest, user: user }

    it 'renders contest JSON' do
      render
      json[:contests].size.should == 5
      json[:contests].each do |_contest|
        _contest.should include :id, :game, :ticket
      end
    end
  end

  context 'with a ticket' do
    let(:contests) { Fabricate.times 1, :contest, user: user }
    let(:ticket) { user.tickets.find_by(contest: contests[0]) }

    it 'renders the current users ticket' do
      render
      json[:contests][0][:ticket].tap do |_json|
        _json[:id].should == ticket.id
        _json.should include :id, :score, :prize_pool, :placing, :user, :contest, :best_or_bust_score
      end
    end

    it 'busts the cache when the ticket score changes' do
      proc do
        stat = Fabricate :stat, game: ticket.game, player: ticket.players.sample, name: :bb, amount: 10
        assign(:tickets, user.tickets.where(contest: contests))
      end.should bust_view_cache
    end

    it 'busts the cache when the ticket username changes' do
      -> {
        user.update(username: 'test123')
        assign(:tickets, user.tickets.where(contest: contests))
      }.should bust_view_cache
    end
  end
end
