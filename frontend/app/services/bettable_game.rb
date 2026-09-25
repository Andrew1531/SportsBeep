class BettableGame

  attr_accessor :game

  def initialize(game)
    @game = game
    @game.activated = true
    @game.bettable  = true
  end

  def call
    return if SportsbookOnly.active?

    determine_league_picks
    assign_default_pools if @game.pools.empty?
    create_contest_templates_for_each_pool
  end

  def call!
    call
    @game.save!
  end

  private

    def determine_league_picks
      @game.league_picks =
        case @game
        when Mlb::Game
          Mlb::GameFrame.new(@game).games
        when Nfl::Game
          Nfl::GameFrame.new(@game).games
        end
    end

    def assign_default_pools
      @game.pools = Pool.where(default: true)
    end

    def create_contest_templates_for_each_pool
      @game.pools.each do |pool|
        template = @game.contest_templates.build(pool: pool)
        best_topics = BestQuestion.sport(@game._sport.name).pluck(:topic_id).uniq.sample(3)
        bust_topics = BustQuestion.sport(@game._sport.name).where.not(topic_id: best_topics).pluck(:topic_id).uniq.sample(3)
        template.best_questions = choose_questions(BestQuestion, best_topics)
        template.bust_questions = choose_questions(BustQuestion, bust_topics)
      end
    end

    def choose_questions(klass, topics)
      topics.map do |topic|
        klass.where(topic_id: topic).all.sample
      end
    end

end