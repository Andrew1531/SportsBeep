class GameFrame

  attr_accessor :game, :games

  def initialize(game)
    @game = game
    calculate
  end

  private

    def calculate
      cutoff = game.start_time + interval
      loop do
        @games = _sport(Game).where(start_time: game.start_time..cutoff).where.not(id: game.id)
        cutoff += interval
        break if @games.size >= 3 || cutoff > (game.start_time + max_time_to_search_ahead)
      end
      @games = ensure_games_do_not_include_the_same_team_twice @games.all
      @games = @games.sample(9) if @games.size > 9
    end

    def interval
      @interval ||= 4.hours
    end

    def ensure_games_do_not_include_the_same_team_twice(games)
      teams = []
      games.select do |game|
        intersect = (game.teams & teams).empty?
        teams.concat(game.teams)
        intersect
      end
    end

end