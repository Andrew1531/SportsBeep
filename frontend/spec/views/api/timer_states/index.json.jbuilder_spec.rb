describe 'api/timer_states/index.json.jbuilder' do
  include_context 'authenticated', :user
  before { assign(:timer_states, timer_states) }

  let(:ticket) { Fabricate :ticket }
  let(:timer_states) { ticket.timer_states }

  it 'displays the encrypted text' do
    render
    json[:timer_states].each do |_json|
      _json.should include :id, :encrypted_text
    end
  end
end