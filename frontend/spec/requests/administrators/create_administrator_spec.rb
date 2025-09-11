describe 'Add an administrator' do
  include_context 'authenticated as admin'

  it 'creates a new administrator' do
    visit admin_administrators_path
    click_link 'Create'
    fill_in 'administrator_email', with: 'test@test.com'
    fill_in 'administrator_password', with: 'qweqweqwe'
    fill_in 'administrator_password_confirmation', with: 'qweqweqwe'
    expect { click_button 'Create' }.to change(Administrator, :count).by 1
    page.current_path.should == admin_administrators_path
  end

  it 'shows an error when the creation failed' do
    visit admin_administrators_path
    click_link 'Create'
    fill_in 'administrator_email', with: 'test@test.com'
    expect { click_button 'Create' }.to_not change(Administrator, :count)
    page.should have_content "can't be blank"
  end

end