describe 'api/questions/index.json.jbuilder' do
  include_context 'authenticated', :user
  let(:ticket) { Fabricate :ticket }
  let(:questions) { Fabricate.times 6, :question }

  before { assign(:questions, questions) }

  it 'renders the questions' do
    render
    json[:questions].size.should == 6
    json[:questions].each do |_json|
      _json.should include :id, :text, :type
      _json[:type].should match /(best|bust)/
    end
  end
end