describe 'Games list', sport: 'Nfl', js: true do
  include_context 'authenticated as user'

  it 'shows a list of bettable games' do
    game = Fabricate :game, as_bettable: true
    nonbettable_game = Fabricate :game
    click_link 'Start New Game'
    within '.games-list' do
      page.should have_content game.home_team.market
      page.should have_content game.away_team.market
      page.should_not have_content nonbettable_game.home_team.market
    end
  end

  it 'each game links to the build a team screen' do
    game = Fabricate :game, as_bettable: true
    click_link 'Start New Game'
    within '.games-list' do
      all('a').first.click
    end
    page.should have_content 'BUILD A TEAM'
  end

end