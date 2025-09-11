describe 'api/pools/index.json.v2.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user
  let(:pools) { Fabricate.times 3, :pool }

  before do
    assign(:pools, pools)
  end

  it 'renders the pools' do
    render
    json[:pools].size.should == 3
    json[:pools].each do |_json|
      _json.should include :id, :prize_pool, :entry_fee
    end
  end
end