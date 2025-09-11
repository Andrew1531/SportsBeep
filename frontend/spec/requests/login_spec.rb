describe 'User login' do

  let(:user) { Fabricate :user }

  it 'logs in' do
    visit play_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Login'
    page.should have_content 'Dashboard'
  end

end