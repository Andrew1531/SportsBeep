describe FavoriteTeam do
  it 'has a valid fabricator' do
    Fabricate(:favorite_team).should be_valid
  end
end
