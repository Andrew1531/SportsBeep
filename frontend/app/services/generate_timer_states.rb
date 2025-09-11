class GenerateTimerStates

  SECONDS = 14
  PRECISION = 10

  def initialize
    @states = []
  end

  def call(ticket)
    0.upto(SECONDS - 1) do |s|
      0.upto(PRECISION) do |p|
        next if s > 0 && p == 0
        @states << build_timer_state(ticket, s, p)
      end
    end
    save
  end

  private

    def build_timer_state(ticket, second, precision)
      state = ticket.timer_states.new
      state.value = ((1.0 * second) + ((1.0 / 10) * precision)).round(4)

      random_salt     = SecureRandom.base64(6)[0..5]
      positional_salt = "#{second}:#{precision}"

      key = ''
      while key.length < 32
        key << ":#{random_salt}:#{positional_salt}:#{ticket.id}:#{random_salt}:"
      end
      key = key.first 32

      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      cipher.key = key
      cipher.iv = key.first 16

      text = random_salt + Base64.encode64(cipher.update("#{positional_salt}:#{state.value}") + cipher.final)
      state.encrypted_text = Base64.encode64(Base64.decode64(text)).gsub("\n", '')
      state
    end

    def save
      TimerState.import @states
    end

end