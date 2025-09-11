describe 'Destroy an administrator' do
  include_context 'authenticated as admin'

  it 'destroys an administrator' do
    target = Fabricate :administrator
    visit admin_administrators_path
    button = find("a[href='#{admin_administrator_path(target)}']")
    expect { button.click }.to change(Administrator, :count).by -1
    page.current_path.should == admin_administrators_path
  end

  it 'cannot destroy itself' do
    visit admin_administrators_path
    expect { click_link 'Delete' }.to_not change(Administrator, :count)
    page.should have_content "Not authorized to do that"
  end

end