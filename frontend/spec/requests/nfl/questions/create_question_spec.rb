describe 'Add a question', sport: 'Nfl' do
  include_context 'authenticated as admin'

  it 'creates a best/bust question' do
    Fabricate :stat_topic, stat: Nfl::Stats::PASSING_YDS.id
    visit new_admin_nfl_question_path
    select 'Passing yards', from: 'question_topic_id'
    fill_in 'question_text', with: 'Which team will have the most passing yards?'
    select 'Best', from: 'question_kind'
    expect { click_button 'Create' }.to change(Question.nfl, :count).by 1
  end

end