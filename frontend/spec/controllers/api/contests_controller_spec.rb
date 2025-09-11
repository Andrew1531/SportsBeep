describe Api::Mlb::ContestsController, version: 2 do
  include_context 'authenticated', :user

  describe 'GET index' do
    describe 'status scoping' do
      let!(:live)     { Fabricate :contest, game: Fabricate(:game, status: :live), user: user  }
      let!(:upcoming) { Fabricate :contest, game: Fabricate(:game, bettable: true), user: user  }
      let!(:ended)    { Fabricate :contest, game: Fabricate(:game, status: :ended), user: user  }
      let!(:past)     { Fabricate :contest, status: :finalized, user: user  }
      let!(:other)    { Fabricate :contest, game: Fabricate(:game, bettable: false) }

      it 'returns live contests' do
        Fabricate :contest, game: Fabricate(:game, status: :ended), status: :finalized, user: user
        get :index, status: :live
        assigns(:contests).should =~ [live, ended]
      end

      it 'returns upcoming contests' do
        get :index, status: :upcoming
        assigns(:contests).should =~ [upcoming, past]
      end

      it 'returns past contests' do
        get :index, status: :past
        assigns(:contests).should =~ [past]
      end

      it 'returns all contests' do
        get :index, status: :abcd
        assigns(:contests).should =~ [live, upcoming, ended, past]
      end
    end

    describe 'pagination' do
      it 'returns a maximum of 20 contests when no page params are sent' do
        Fabricate.times 25, :contest, user: user
        get :index
        assigns(:contests).size.should == 20
      end

      it 'accepts a page parameter' do
        Fabricate.times 25, :contest, user: user
        get :index, page: 2
        assigns(:contests).size.should == 5
      end

      it 'accepts a per parameter' do
        Fabricate.times 25, :contest, user: user
        get :index, page: 1, per: 10
        assigns(:contests).size.should == 10
      end
    end

    describe 'sorting' do
      it 'sorts by game start time and then home team name' do
        time = 2.days.from_now
        c1 = Fabricate :contest, game: Fabricate(:game, start_time: 4.days.from_now, home_team: Fabricate(:team, name: 'A')), user: user
        c4 = Fabricate :contest, game: Fabricate(:game, start_time: time,            home_team: Fabricate(:team, name: 'D')), user: user
        c2 = Fabricate :contest, game: Fabricate(:game, start_time: 3.days.from_now, home_team: Fabricate(:team, name: 'B')), user: user
        c3 = Fabricate :contest, game: Fabricate(:game, start_time: time,            home_team: Fabricate(:team, name: 'C')), user: user
        get :index
        assigns(:contests).should == [c1, c2, c3, c4]
      end
    end

    # describe 'http caching', version: 2 do
    #   let!(:contest) { Fabricate :contest, user: user }

    #   it 'busts cache when contest is updated' do
    #     -> { contest.touch }.should bust_cache(:index)
    #   end

    #   it 'busts cache when ticket is updated' do
    #     -> { contest.tickets[0].touch }.should bust_cache(:index)
    #   end
    # end
  end

  describe 'GET show' do
    describe 'http caching', version: 2 do
      let!(:contest) { Fabricate :contest, user: user }

      it 'assigns the contest from the ID param' do
        get :show, id: contest
        assigns(:contest).should == contest
      end

      it 'returns a 401 when trying to view a contest that isnt mine' do
        c2 = Fabricate :contest
        get :show, id: c2
        response.status.should == 401
      end

      # it 'busts cache on contest update' do
      #   -> { contest.touch }.should bust_cache(:show, id: contest)
      # end
    end
  end

end