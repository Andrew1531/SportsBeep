class CardanoSwapConfirmationJob < ActiveJob::Base
  queue_as :default
  def perform(swap_id)
    swap = CardanoSwap.find_by(id: swap_id)
    return unless swap && CardanoSwap.pollable.where(id: swap.id).exists?
    status = CardanoSwapConfirmationService.new.call(swap)
    self.class.set(wait: 15.seconds).perform_later(swap.id) if %w[pending paying].include?(status)
  end
end