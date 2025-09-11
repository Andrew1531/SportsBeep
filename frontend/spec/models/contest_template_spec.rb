describe ContestTemplate do

  describe 'Fabricator' do
    it 'is valid' do
      template = Fabricate :contest_template
      template.should be_valid
      template.questions.size.should == 6
    end
  end

end
