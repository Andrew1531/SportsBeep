class BeepWithdrawalConfirmationJob < ActiveJob::Base
  queue_as :default

  RETRY_DELAY = 15.seconds

  def perform(transfer_id)
    transfer = BeepChainTransfer.find_by(id: transfer_id)
    return unless transfer&.direction == 'withdrawal'

    status = BeepWithdrawalConfirmationService.new.call(transfer)
    if BeepWithdrawalConfirmationService::POLLABLE_STATUSES.include?(status)
      self.class.set(wait: RETRY_DELAY).perform_later(transfer.id)
    end
  end
end