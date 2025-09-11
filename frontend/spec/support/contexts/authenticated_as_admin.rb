shared_context 'authenticated as admin' do
  before do
    admin = Fabricate :administrator
    visit admin_root_path
    fill_in 'administrator_email', with: admin.email
    fill_in 'administrator_password', with: admin.password
    click_button 'Login'
  end
end