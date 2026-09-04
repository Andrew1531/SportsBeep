class BeepDepositConfirmationJob < ActiveJob::Base
  queue_as :default

  RETRY_DELAY = 15.seconds

  def perform(transfer_id)
    transfer = BeepChainTransfer.find_by(id: transfer_id)
    return unless transfer&.direction == 'deposit' && transfer.status == 'pending'

    status = BeepDepositConfirmationService.new.call(transfer)
    self.class.set(wait: RETRY_DELAY).perform_later(transfer.id) if status == 'pending'
  end
end