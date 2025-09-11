shared_context 'authenticated' do |type|
  let(:user) { Fabricate type }

  before do
    view.stub(:current_user) { user } if defined?(view)
    request.env['HTTP_AUTHORIZATION'] = "Token token=#{user.authentication_token}" if request
  end

end

shared_context 'authenticated as user' do
  let(:user) { Fabricate :user }

  before do
    visit play_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Login'
  end
end