describe 'Adding a promo code' do
  include_context 'authenticated as admin'

  it 'creates a new promo code' do
    visit new_admin_promo_code_path
    fill_in 'promo_code_code', with: 'TEST123'
    fill_in 'promo_code_note', with: 'TEST123 Note'
    click_button 'Create'
    PromoCode.first.code.should == 'TEST123'
    PromoCode.first.note.should == 'TEST123 Note'
  end

  it 'shows error messages' do
    visit new_admin_promo_code_path
    click_button 'Create'
    page.should have_content "Code can't be blank"
  end

end