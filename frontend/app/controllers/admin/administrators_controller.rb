class Admin::AdministratorsController < Admin::BaseController

  def index
    @administrators = Administrator.all
  end

  def new
    @administrator = Administrator.new
  end

  def create
    @administrator = Administrator.create permitted_params
    respond_with @administrator, location: admin_administrators_path
  end

  def destroy
    @administrator = Administrator.find params[:id]
    authorize @administrator, :destroy?
    @administrator.destroy
    respond_with @administrator, location: admin_administrators_path
  end

  private

    def permitted_params
      params.require(:administrator).permit :email, :password, :password_confirmation
    end

end
