module Paginable
  extend ActiveSupport::Concern

  def paginate(scope)
    page = params[:page] || 1
    per = params[:per] || 20
    scope.page(page).per(per)
  end

end