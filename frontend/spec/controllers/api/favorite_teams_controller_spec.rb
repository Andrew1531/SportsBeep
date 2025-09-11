describe Api::FavoriteTeamsController, version: 2 do
  include_context 'authenticated', :user

  describe 'PUT update' do
    context 'baseball', sport: 'Mlb' do
      let(:team) { Fabricate :team }

      it 'sets the users favorite baseball team' do
        expect {
          put :update, favorite_team: { baseball: team.id }
        }.to change { user.reload.favorite_team.baseball }.from(nil).to(team)
      end
    end
  end

end
