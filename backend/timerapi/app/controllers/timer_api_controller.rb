# default is to render method in views/

class TimerApiController < ApplicationController
	def ticket_timer_states_get
    while Ticket.find_by({ ticket_number: params[:ticket_number] }) != nil
      Ticket.find_by({ ticket_number: params[:ticket_number] }).destroy
    end

    ticket = Ticket.new({ ticket_number: params[:ticket_number]})
    ticket.save

    seconds = params[:seconds].to_s.to_i
    precision = params[:precision].to_s.to_i

    # slight sanity
    seconds = 1 if seconds <= 0
    precision = 1 if precision <= 0 || precision % 10 != 0
    precision = 1000 if precision > 1000

#    d = []

    { :name => "vin", :type => "record" }

    0.upto(seconds - 1) do |s|
      0.upto(precision) do |p|
        next if s > 0 and p == 0
        state_value = (1.0 * s + 1.0 / precision * p).round(4)

        random_salt = SecureRandom.base64(6)[0..5]
        positional_salt = s.to_s + ':' + p.to_s

        key = ''
        key = key + ':' + random_salt + ':' + positional_salt + ':' + params[:ticket_number] + ':' + random_salt + ':' while key.length < 32
        key = key.to_s[0..31] if key.length > 32

        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.encrypt
        cipher.key = key
        cipher.iv = key.to_s[0..15]

        state_text = random_salt + Base64.encode64(cipher.update(positional_salt + ':' + state_value.to_s) + cipher.final)
        state_text = Base64.encode64(Base64.decode64(state_text)).gsub("\n", '')

        ticket.ticket_timer_states.new({ state_text: state_text, state_value: state_value }).save

#        d.push({ s: s, p: p, random_salt: random_salt, positional_salt: positional_salt, key: key, state_value: state_value, state_text: state_text })
      end
    end

#    d.push(ticket.ticket_timer_states.select('state_text').order('state_text DESC'))
#    render json: d
    render json: { error_number: 0, error_text: '', contract_version: 1, result: ticket.ticket_timer_states.select('state_text').order('state_text DESC') }
	end

	def ticket_question_answer_set
    ticket = Ticket.find_by({ ticket_number: params[:ticket_number] })
    if ticket != nil
      state = ticket.ticket_timer_states.find_by({ state_text: params[:timer_state_text] })
      if state != nil
        ticket_answer = ticket.ticket_answers.find_by({ question_number: params[:question_number] })
        if ticket_answer == nil
          ticket.ticket_answers.new({ question_number: params[:question_number], answer: params[:answer], answer_time: state.state_value }).save
          render json: { error_number: 0, error_text: '' }
        else
          render json: { error_number: 3, error_text: 'question already answered' }
        end
      else
        render json: { error_number: 2, error_text: 'state_text invalid for ticket_id' }
      end
    else
      render json: { error_number: 1, error_text: 'ticket_id not found' }
    end
  end

end # class
