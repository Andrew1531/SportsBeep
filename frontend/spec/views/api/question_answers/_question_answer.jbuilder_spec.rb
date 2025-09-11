describe 'api/resources/_question_answer.jbuilder' do
  include_context 'authenticated', :user
  let(:answer) { Fabricate :question_answer, time: 1.1 }

  before do
    view.stub(:answer) { answer }
  end

  it 'renders to a max of 1 decimal place' do
    allow(answer).to receive(:correct?) { true }
    render
    json[:score].should == '0.2'
  end

  it 'renders whole numbers without the .0' do
    answer = Fabricate :question_answer, time: 100
    allow(answer).to receive(:correct?) { true }
    render
    json[:score].should == '0'
  end
end

