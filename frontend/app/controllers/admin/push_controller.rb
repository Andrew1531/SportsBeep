class Admin::PushController < Admin::BaseController

  def new
    @push = Push.new
  end

  def create
    @push = Push.new(permitted_params)
    resp = @push.push
    if (status = resp.first[:status_code]) == 200
      flash[:success] = 200
    else
      flash[:alert] = status
    end
    render :new
  end

  private

    def permitted_params
      params.require(:push).permit(:email, :type)
    end

end
