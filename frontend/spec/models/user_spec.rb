describe User do
  it "requires a password" do
    user = Fabricate.build :user, password: nil
    user.should be_invalid
    user.errors[:password].should include "can't be blank"
  end

  it "creates one and only one favorite team" do
    user = Fabricate :user
    user.favorite_team.should be_present
    expect(user).to_not receive :build_favorite_team
    user.update(username: 'testerino')
    FavoriteTeam.count.should == 1
  end

  it 'must have the platform set to be ios or android if present' do
    Fabricate.build(:user, platform: 'ios').should       be_valid
    Fabricate.build(:user, platform: 'android').should   be_valid
    Fabricate.build(:user, platform: nil).should         be_valid
    Fabricate.build(:user, platform: 'something').should be_invalid
  end

  describe '#<<' do
    let(:agent) { Fabricate :user }
    let(:child) { Fabricate :user }

    it 'adds a user to the agents MLM tree' do
      agent << child
      agent.should be_agent
      became_agent_at = agent.became_agent_at
      became_agent_at.should be_present
      Timecop.travel(10.minutes.from_now) do
        agent << Fabricate(:user)
        agent.children.size.should == 2
        agent.became_agent_at.should == became_agent_at
      end
    end
  end

  describe '#agent?' do
    let(:agent) { Fabricate :user }
    let(:child) { Fabricate :user }

    it 'returns true if the user has children' do
      agent.should_not be_agent
      agent << child
      agent.should be_agent
    end
  end

  describe '#eligible_for_commission?' do
    let(:agent) { Fabricate :user }
    let(:child) { Fabricate :user }

    it 'returns false if the user is not an agent' do
      agent.should_not be_agent
      agent.should_not be_eligible_for_commission
    end
  end

end
