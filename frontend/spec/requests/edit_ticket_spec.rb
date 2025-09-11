describe 'Editing ticket', sport: 'Nfl', js: true do
  include_context 'authenticated as user'

  let!(:ticket) do
    Fabricate :ticket, user: user
  end

  before do
    click_button 'Upcoming'
    page.should have_selector '.contests-outer-container .contest'
    within '.contests-outer-container' do
      all('a').first.click
    end
  end

  it 'shows the ticket in the list of upcoming contests' do
    within '.tickets' do
      page.should have_css '.ticket-card', count: 1
      find('.ticket-card').click
    end
  end

  it 'edits players on a ticket' do
    pending
    # visit "/play#/dashboard/tickets/#{ticket.id}"
    # page.should have_css '.player-cards'

    # # click to change RB
    # all('.player-card').first.click
    # ticket.game.players.where(position: 'RB').sample(3).each do |rb|
    #   page.should have_content rb.last_name.upcase
    # end

    # # select a new RB
    # all('.player-card').first.click

    # page.should have_content 'Update Your Ticket'
    # click_button 'Update Your Ticket'
    # page.should have_css '.fa-check'

  end

end