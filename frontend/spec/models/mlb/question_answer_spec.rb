describe QuestionAnswer, sport: 'Mlb' do

  describe '#correct?' do
    let(:team)   { Fabricate :team }
    let(:game)   { Fabricate :game, home_team: team }
    let(:ticket) { Fabricate :ticket, game: game }

    let(:answer) do
      Fabricate :question_answer, question: question, answer: team, ticket: ticket
    end

    before do
      stat = Fabricate :stat, team: team, game: game, stat: Mlb::Stats::HOME_RUNS, amount: 5
      stat = Fabricate :stat, team: game.away_team, game: game, stat: Mlb::Stats::HOME_RUNS, amount: 2
    end

    context 'when stat comparison is MORE' do
      before do
        Fabricate :stat, team: team,           game: game, stat: Mlb::Stats::HOME_RUNS, amount: 5
        Fabricate :stat, team: game.away_team, game: game, stat: Mlb::Stats::HOME_RUNS, amount: 2
      end

      context 'when question is BEST' do
        let(:question) { Fabricate :best_question, topic: Mlb::Stats::HOME_RUNS, text: 'Which team will get more home runs?' }
        it 'returns true when answer has more stats than the other team' do
          answer.should be_correct
        end
      end

      context 'when question is BUST' do
        let(:question) { Fabricate :bust_question, topic: Mlb::Stats::HOME_RUNS, text: 'Which team will not get more home runs?' }
        it 'returns false when answer has more stats than the other team' do
          answer.should be_incorrect
        end
      end
    end

    context 'when stat comparison is LESS' do
      before do
        Fabricate :stat, team: team,           game: game, stat: Mlb::Stats::ERRORS, amount: 5
        Fabricate :stat, team: game.away_team, game: game, stat: Mlb::Stats::ERRORS, amount: 2
      end

      context 'when question is BEST' do
        let(:question) { Fabricate :best_question, topic: Mlb::Stats::ERRORS, text: 'Which team will get more errors?', comparison: :less }
        it 'returns false when answer has more stats than the other team' do
          answer.should be_incorrect
        end
      end

      context 'when question is BUST' do
        let(:question) { Fabricate :bust_question, topic: Mlb::Stats::ERRORS, text: 'Which team will not get more errors?', comparison: :less }
        it 'returns true when answer has more stats than the other team' do
          answer.should be_correct
        end
      end
    end

  end
end

describe QuestionAnswer, sport: 'Nfl' do

  describe '#correct?' do
    let(:team)   { Fabricate :team }
    let(:game)   { Fabricate :game, home_team: team }
    let(:ticket) { Fabricate :ticket, game: game }

    let(:answer) do
      Fabricate :question_answer, question: question, answer: team, ticket: ticket
    end

    context 'when stat comparison is MORE' do
      before do
        Fabricate :team_game_stat, team: team, game: game, stat: Nfl::Stats::CHALLENGES, amount: 5
        Fabricate :team_game_stat, team: game.away_team, game: game, stat: Nfl::Stats::CHALLENGES, amount: 2
      end

      context 'when question is BEST' do
        let(:question) { Fabricate :best_question, topic: Nfl::Stats::CHALLENGES, text: 'Which team will have more challenges?' }
        it 'returns true when answer has more stats than the other team' do
          answer.should be_correct
        end
      end

      context 'when question is BUST' do
        let(:question) { Fabricate :bust_question, topic: Nfl::Stats::CHALLENGES, text: 'Which team will have less challenges?' }
        it 'returns false when answer has more stats than the other team' do
          answer.should be_incorrect
        end
      end
    end

    context 'when stat comparison is LESS' do
      before do
        Fabricate :team_game_stat, team: team, game: game, stat: Nfl::Stats::PENALTIES, amount: 5
        Fabricate :team_game_stat, team: game.away_team, game: game, stat: Nfl::Stats::PENALTIES, amount: 2
      end

      context 'when question is BEST' do
        let(:question) { Fabricate :best_question, topic: Nfl::Stats::PENALTIES, text: 'Which team will take more penalties?', comparison: :less }
        it 'returns false when answer has more stats than the other team' do
          answer.should be_incorrect
        end
      end

      context 'when question is BUST' do
        let(:question) { Fabricate :bust_question, topic: Nfl::Stats::PENALTIES, text: 'Which team will not take more penalties?', comparison: :less }
        it 'returns true when answer has more stats than the other team' do
          answer.should be_correct
        end
      end
    end

  end
end

