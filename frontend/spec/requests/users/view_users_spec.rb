describe 'Viewing users in the admin portal' do
  include_context 'authenticated as admin'
  let(:admin) { Fabricate :admin }

  describe 'GET #index' do
    it 'shows users' do
      users = Fabricate.times 2, :user
      visit admin_users_path
      users.each do |user|
        page.should have_content user.email
      end
    end

    it 'paginates the users' do
      Fabricate.times 50, :user
      visit admin_users_path
      all('#users tbody tr').size.should == 25
      page.should have_content 'Users (50)'
      page.should have_selector '.pagination'
    end
  end

  describe 'GET #show' do
    let(:user) { Fabricate :user }

    it 'shows the users info' do
      visit admin_user_path(user)
      page.should have_content user.email
      page.should have_content user.username
      page.should have_content user.device_token
      page.should have_content user.platform
      page.should have_content user.id
    end
  end
end