describe 'api/question_answers/index.json.v2.jbuilder' do
  include_context 'authenticated', :user
  let(:answers) { Fabricate.times 6, :question_answer }

  before { assign(:answers, answers) }

  it 'renders the answers' do
    render
    json[:answers].each do |_json|
      _json.should include :time, :score, :correct, :question, :team
      _json[:question].should include :id, :text, :type
      _json[:team].should include :id
    end
  end

end

