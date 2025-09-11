describe 'Editing global settings' do
  include_context 'authenticated as admin'
  let(:admin) { Fabricate :admin }

  describe 'PUT #update' do
    it 'updates a users password' do
      visit admin_setting_path
      find('#setting_require_promo_code_on_signup').set(true)
      expect { click_button 'Update' }.to change { Setting.first.require_promo_code_on_signup }.from(false).to(true)
    end
  end
end