shared_examples_for 'question_answers#index' do
  include_context 'authenticated', :user

  describe 'GET index' do
    let(:ticket) { Fabricate :ticket}

    it 'returns a list of my answers' do
      Fabricate.times 6, :question_answer, ticket: ticket
      get :index, ticket_id: ticket
      json[:answers].each do |_json|
        _json.should include :time, :score, :correct, :question, :team
        _json[:question].should include :id, :text, :type
        _json[:team].should include :id
      end
    end
  end

end