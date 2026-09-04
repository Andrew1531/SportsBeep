# Bridge to the Node-based Cardano transaction tool (cardano-tools/beep-tool.mjs),
# which handles transaction building and treasury payouts via Mesh SDK.
require 'open3'
require 'json'
require 'fileutils'

class CardanoTxTool
  TOOL_DIR = Rails.root.join('..', 'cardano-tools').to_s
  TREASURY_PAYOUT_LOCK_ID = 7_311_927_487
  # Covers the token output's minimum ADA plus a conservative transaction fee.
  # This is only a friendly preflight; the builder remains authoritative.
  MIN_PAYOUT_LOVELACE = 2_000_000

  class Error < StandardError
    attr_reader :stage, :tx_hash

    def initialize(message, stage: nil, tx_hash: nil)
      @stage = stage
      @tx_hash = tx_hash
      super(message)
    end

    # True when a payout failed at the submit step — the transaction may have
    # reached the network, so the caller must NOT refund automatically.
    def ambiguous_submission?
      stage == 'submit'
    end
  end

  def self.treasury_address
    run('address')['address']
  end

  def self.find_beep_unit(address)
    result = run('find-unit', address)
    { unit: result['unit'], quantity: result['quantity'].to_i }
  end

  def self.find_unit(address, unit)
    return { unit: 'lovelace', quantity: BlockfrostService.new.get_lovelace_balance(address) } if unit == 'lovelace'
    result = run('find-unit', address, unit)
    { unit: result['unit'], quantity: result['quantity'].to_i }
  end

  def self.build_deposit(user_address:, treasury_address:, unit:, amount:)
    run('build-deposit', user_address, treasury_address, unit, amount.to_s)['unsigned_tx']
  end

  def self.build_payout(to_address:, unit:, amount:)
    result = run('build-payout', to_address, unit, amount.to_s)
    { signed_tx: result['signed_tx'], tx_hash: result['tx_hash'] }
  end

  def self.submit_payout(signed_tx)
    run('submit-payout', signed_tx)['tx_hash']
  end

  # Treasury UTxOs must be selected and submitted serially. Otherwise two
  # simultaneous withdrawals can build against the same input and one fails.
  def self.with_payout_lock
    connection = ActiveRecord::Base.connection
    if connection.adapter_name.downcase.include?('postgres')
      connection.select_value("SELECT pg_advisory_lock(#{TREASURY_PAYOUT_LOCK_ID})")
      begin
        return yield
      ensure
        connection.select_value("SELECT pg_advisory_unlock(#{TREASURY_PAYOUT_LOCK_ID})")
      end
    end

    # SQLite development fallback. PostgreSQL's advisory lock above also
    # serializes payouts across separate deployment instances.
    lock_path = Rails.root.join('tmp', 'cardano-treasury-payout.lock')
    FileUtils.mkdir_p(lock_path.dirname)
    File.open(lock_path, File::RDWR | File::CREAT, 0o600) do |file|
      file.flock(File::LOCK_EX)
      yield
    ensure
      file.flock(File::LOCK_UN)
    end
  end

  def self.run(*args)
    stdout, stderr, status = Open3.capture3('node', 'beep-tool.mjs', *args, chdir: TOOL_DIR)
    line = stdout.lines.reverse.find { |l| l.strip.start_with?('{') }
    parsed =
      begin
        line && JSON.parse(line)
      rescue JSON::ParserError
        nil
      end
    if parsed.nil?
      Rails.logger.error "CardanoTxTool #{args.first} failed: #{stderr.presence || stdout}"
      raise Error, 'Blockchain tool error'
    end
    unless parsed['ok']
      raise Error.new(parsed['error'].to_s, stage: parsed['stage'], tx_hash: parsed['tx_hash'])
    end

    parsed
  end
  private_class_method :run
end
