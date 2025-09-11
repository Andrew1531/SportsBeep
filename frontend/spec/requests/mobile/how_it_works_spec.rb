describe 'How It Works page' do

  it 'shows the How It Works header' do
    visit how_it_works_mobile_pages_path
    page.should have_content 'Rules & Scoring'
  end

end