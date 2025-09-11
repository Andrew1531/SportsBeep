shared_examples_for 'a roster importer' do
  it 'pulls down the list of teams from SportsData' do
    subject.perform
    WebMock.should have_requested(:get, url)
    model.count.should == count
  end

  it 'updates existing team records if we have polled it before' do
    subject.perform
    expect { subject.perform }.to_not change(model, :count)
  end

  it 'creates new team records if one isnt there already' do
    subject.perform
    model.last.destroy
    expect { subject.perform }.to change(model, :count).by 1
  end
end