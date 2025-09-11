describe 'Money transactions throughout the contest life cycle' do

  specify 'a user is charged an entry fee when joining a contest' do
    # contest.rb, l38
  end

  specify 'a user is refunded the entry fee if a contest is canceled' do
    # contest.rb, l52
  end

  context 'after contest is finalized' do
    # need to figure out contest.rb lines 70-87

    specify 'a user is awarded their payout for the contest' do
      # contest.rb, l90
    end

    describe 'Settling commission' do
      specify 'commission is awarded to all parents of the user' do
        # contest.rb, l130
      end

      specify 'commission is not awarded to parents who are ineligible' do
      end

    end

    specify 'promotional balance is released based on the contest entry fee and promo release rate' do
    end
  end

end