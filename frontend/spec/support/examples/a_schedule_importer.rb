shared_examples_for 'a schedule importer' do

  it 'pulls down the list of games from SportsData' do
    subject.perform
    WebMock.should have_requested(:get, url)
  end

  it 'updates existing game records if we have polled it before' do
    subject.perform
    expect { subject.perform }.to_not change(model, :count)
  end

  it 'creates new team records if one isnt there already' do
    subject.perform
    model.last.destroy
    expect { subject.perform }.to change(model, :count).by 1
  end

  it 'sets the home/away teams and start time' do
    subject.perform
    model.all.each do |game|
      game.home_team.should be_present
      game.away_team.should be_present
      game.start_time.should be_between(1.year.ago, 1.year.from_now)
    end
  end

end