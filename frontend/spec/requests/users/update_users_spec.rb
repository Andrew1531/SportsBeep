describe 'Editing users in the admin portal' do
  include_context 'authenticated as admin'
  let(:admin) { Fabricate :admin }

  describe 'PUT #update' do
    it 'updates a users password' do
      user = Fabricate :user, password: 'metova12345'
      visit admin_user_path(user)
      fill_in 'user_password', with: 'new-pw-test-123'
      click_button 'Update User'
      page.should have_content 'User was successfully updated.'
      user.reload.valid_password?('new-pw-test-123').should == true
    end

    it 'paginates the users' do
      Fabricate.times 50, :user
      visit admin_users_path
      all('#users tbody tr').size.should == 25
      page.should have_content 'Users (50)'
      page.should have_selector '.pagination'
    end
  end
end