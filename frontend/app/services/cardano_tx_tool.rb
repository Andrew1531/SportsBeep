# Bridge to the Node-based Cardano transaction tool (cardano-tools/beep-tool.mjs),
# which handles transaction building and treasury payouts via Mesh SDK.
require 'open3'
require 'json'
require 'shellwords'

class CardanoTxTool
  TOOL_DIR = Rails.root.join('..', 'cardano-tools').to_s

  class Error < StandardError
    attr_reader :stage

    def initialize(message, stage: nil)
      @stage = stage
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

  def self.build_deposit(user_address:, treasury_address:, unit:, amount:)
    run('build-deposit', user_address, treasury_address, unit, amount.to_s)['unsigned_tx']
  end

  def self.payout(to_address:, unit:, amount:)
    run('payout', to_address, unit, amount.to_s)['tx_hash']
  end

  def self.run(*args)
    cmd = ['node', 'beep-tool.mjs', *args].shelljoin
    stdout, stderr, status = Open3.capture3(cmd, chdir: TOOL_DIR)
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
    raise Error.new(parsed['error'].to_s, stage: parsed['stage']) unless parsed['ok']

    parsed
  end
  private_class_method :run
end
