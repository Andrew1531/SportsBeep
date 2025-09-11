module MLM
  extend ActiveSupport::Concern

  def <<(user)
    update(became_agent_at: Time.current) if children.count == 0
    user.update parent: self
  end

  def agent?
    has_children?
  end

  def eligible_for_commission?
    agent? #&& retail.active.count > 10
  end

  # def retail
  #   User.children_of(self)
  #   children.reject &:agent?
  # end

end