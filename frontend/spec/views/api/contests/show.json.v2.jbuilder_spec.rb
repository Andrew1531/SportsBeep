describe 'api/contests/show.json.v2.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user
  before { assign(:contest, contest) }

  let(:contest) { Fabricate :contest, user: user }

  it 'returns the contest ID and game ID' do
    render
    json.should include :id
    json.should include :game
    json[:game].should include :id
  end

end