describe LineupPosition do

  it 'maps integer positions to string' do
    Fabricate(:lineup_position, position: 1).position.should == 'SP'
    Fabricate(:lineup_position, position: 2).position.should == 'C'
    Fabricate(:lineup_position, position: 3).position.should == '1B'
    Fabricate(:lineup_position, position: 4).position.should == '2B'
    Fabricate(:lineup_position, position: 5).position.should == '3B'
    Fabricate(:lineup_position, position: 6).position.should == 'SS'
    Fabricate(:lineup_position, position: 7).position.should == 'LF'
    Fabricate(:lineup_position, position: 8).position.should == 'CF'
    Fabricate(:lineup_position, position: 9).position.should == 'RF'
    Fabricate(:lineup_position, position: 10).position.should == 'DH'
    Fabricate(:lineup_position, position: 11).position.should == 'PH'
    Fabricate(:lineup_position, position: 12).position.should == 'PR'
    Fabricate(:lineup_position, position: 13).position.should == nil
  end

end
