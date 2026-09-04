# Recover confirmation polling after a web process restart. The confirmation
# services are idempotent, so duplicate jobs from multiple web workers are safe.
Rails.application.config.after_initialize do
  next unless defined?(Rails::Server)
  next unless ActiveRecord::Base.connection.data_source_exists?('beep_chain_transfers')

  BeepChainTransfer.deposits.pending.find_each do |transfer|
    BeepDepositConfirmationJob.perform_later(transfer.id)
  end

  BeepChainTransfer.withdrawals.where(status: BeepWithdrawalConfirmationService::POLLABLE_STATUSES).find_each do |transfer|
    BeepWithdrawalConfirmationJob.perform_later(transfer.id)
  end
rescue StandardError => e
  Rails.logger.error "BEEP transfer recovery startup error: #{e.class}: #{e.message}"
end