describe Mlb::Player do

  describe '#just_injured?' do
    let(:player) { Fabricate 'Mlb::Player' }

    context 'when player is already injured' do
      before { player.update(status: 'D7') }

      it 'returns false if injured' do
        player.status = 'D15'
        player.just_injured?.should == false
      end
    end

    context 'when player is not injured' do
      before { player.update(status: 'A') }

      it 'returns true if becomes injured' do
        player.status = 'D7'
        player.just_injured?.should == true
      end

      it 'returns false if becomes not injured' do
        player.status = 'ASG'
        player.just_injured?.should == false
      end
    end

  end
end
