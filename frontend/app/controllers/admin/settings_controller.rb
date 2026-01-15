class Admin::SettingsController < Admin::BaseController

  before_action :set_setting

  def show
    render :edit
  end

  def edit
  end

  def update
    if @setting
      if @setting.update(permitted_params)
        flash[:success] = "Settings updated successfully!"
      else
        flash[:alert] = "Failed to update settings."
      end
    else
      flash[:alert] = "No settings record found. Please run database seeds."
    end
    redirect_to admin_setting_path
  end

  private

    def set_setting
      @setting = Setting.first_or_create
    end

    def permitted_params
      params.require(:setting).permit :require_promo_code_on_signup
    end

end
