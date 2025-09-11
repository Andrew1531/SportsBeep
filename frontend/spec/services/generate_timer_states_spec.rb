describe GenerateTimerStates, sport: 'Mlb' do

  it 'generates 141 timer states (1 for each tenth of a second)' do
    ticket = Fabricate :ticket
    ticket.reload.timer_states.size.should == 141
  end

end
