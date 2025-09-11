describe 'Add a question', sport: 'Mlb' do
  include_context 'authenticated as admin'

  it 'creates a best/bust question' do
    Fabricate :stat_topic, stat: Mlb::Stats::WALKS.id
    visit new_admin_mlb_question_path
    select 'Walks', from: 'question_topic_id'
    fill_in 'question_text', with: 'Which team will have the most walks?'
    select 'Best', from: 'question_kind'
    expect { click_button 'Create' }.to change(Question.mlb, :count).by 1
  end

end