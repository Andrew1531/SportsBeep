describe 'api/registrations/create.json.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user

  before do
    view.stub(:resource) { user }
  end

  it 'includes the authentication token' do
    render
    json.should include :authentication_token
  end

end
