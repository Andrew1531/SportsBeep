class Admin::SettingsController < Admin::BaseController

  before_action :set_setting

  def show
    render :edit
  end

  def edit
  end

  def update
    @setting.update permitted_params
    respond_with @setting, location: admin_setting_path
  end

  private

    def set_setting
      @setting = Setting.first
    end

    def permitted_params
      params.require(:setting).permit :require_promo_code_on_signup
    end

end
