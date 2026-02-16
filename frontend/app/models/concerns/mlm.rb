module MLM
  extend ActiveSupport::Concern

  def agent?
    false
  end

  def eligible_for_commission?
    false
  end

end
