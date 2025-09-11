describe 'api/resources/_stat.jbuilder' do
  include_context 'authenticated', :user

  describe '3 decimal' do
    [
      Mlb::Stats::SLUGGING_PCT,
      Mlb::Stats::BATTING_AVERAGE,
      Mlb::Stats::ON_BASE_PCT,
      Mlb::Stats::ON_BASE_AVERAGE
    ].each do |statdata|
      it 'displays as a 3-decimal float no matter what' do
        stat = Fabricate :stat, stat: statdata, amount: 0.25
        view.stub(:stat) { stat }
        render
        json[:amount].should == '.250'
      end
    end
  end

  describe '2 decimal' do
    [
      Mlb::Stats::ERA,
      Mlb::Stats::WHIP
    ].each do |statdata|
      it 'displays as a 2-decimal float' do
        stat = Fabricate :stat, stat: statdata, amount: 2.3
        view.stub(:stat) { stat }
        render
        json[:amount].should == '2.30'
      end
    end
  end

  describe '2 decimal rounded' do
    [
      Mlb::Stats::SINGLES,
      Mlb::Stats::DOUBLES,
      Mlb::Stats::TRIPLES,
      Mlb::Stats::HOME_RUNS
    ].each do |statdata|
      it 'displays as a 2-decimal float' do
        stat = Fabricate :stat, stat: statdata, amount: 1.2345342
        view.stub(:stat) { stat }
        render
        json[:amount].should == '1.23'
      end
    end
  end

end