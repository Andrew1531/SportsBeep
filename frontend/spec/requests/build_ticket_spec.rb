describe 'Games list', sport: 'Nfl', js: true do
  include_context 'authenticated as user'

  let!(:game) do
    Fabricate :game, as_bettable: true
  end

  before do
    click_link 'Start New Game'
    page.should have_selector '.game-card'
    within '.games-list' do
      all('a').first.click
    end
    page.should have_content "SELECT A RUNNING BACK"
  end

  it 'chooses players for the positions' do
    page.should have_content "SELECT A RUNNING BACK"
    within '.player-cards' do
      all('a .card-container').first.click
      game.players.where(position: 'RB').each do |rb|
        page.should have_content rb.last_name.upcase
      end
    end

    # select the first player in the list
    all('.card-container').first.click

    within '.player-cards' do
      page.should have_selector 'svg'
    end
  end

  it 'chooses squads for the position' do
    page.should have_content "SELECT A SPECIAL TEAMS SQUAD"
    within '.player-cards' do
      all('a .card-container').last.click
    end

    within '.overlay' do
      page.should have_selector('polygon', count: 2)
      all('.away-team').first.click
    end

    within '.squad-card svg text' do
      page.should have_content game.away_team.name
    end
  end

  it 'finalizes the ticket' do
    # choose all players
    ['RUNNING BACK', 'WIDE RECEIVER', 'TIGHT END', 'FLEX PLAYER', 'KICKER'].each_with_index do |text, i|
      all('.player-card')[i].click
      page.should have_content text
      all('.card-container').first.click
      page.should have_content 'YOUR PLAYERS'
    end

    # choose all squads
    all('.squad-card').each do |sc|
      sc.click
      within '.overlay' do
        page.should have_selector('polygon', count: 2)
        all('.away-team').first.click
      end
    end

    click_button 'Set your team'
    page.should have_content 'What pool would you like to enter?'

    find('.confirm-pool-btn').click
    page.should have_content game.home_team.market
    page.should have_content game.home_team.name
    page.should have_content game.away_team.market
    page.should have_content game.away_team.name

    expect {
      find('.confirm-payment-btn').click
      page.should have_content 'Quiz Time'
    }.to change(Ticket, :count).by 1

    find('.start-questions-btn').click

    # answer all the b&b questions
    6.times do
      page.should have_selector 'polygon'
      within '.overlay' do
        all('.away-team').first.click
      end
    end

    page.should have_content 'SUBMITTING ANSWERS...'
    page.should have_content 'You have joined this contest!'

    click_link 'View Ticket'
    Ticket.last.players.each do |player|
      page.should have_content player.number
    end

  end
end