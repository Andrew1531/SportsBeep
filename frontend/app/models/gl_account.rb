class GlAccount < ActiveRecord::Base

  monetize :balance_cents
  before_validation { self.balance_cents ||= 0 }

  def self.[](name)
    find_or_create_by(name: name)
  end

  def add(money)
    update balance: (balance + money)
  end

  def subtract(money)
    update balance: (balance - money)
  end

end
