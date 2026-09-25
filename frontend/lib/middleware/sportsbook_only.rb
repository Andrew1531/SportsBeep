# Retirement policy is deliberately code-only. Reintroducing fantasy requires
# an explicit rebuild, not an environment switch or a user preference.
class SportsbookOnly
  MESSAGE = 'Fantasy is unavailable. Sportsbook only.'.freeze

  def self.active?
    true
  end

  def self.retired_path?(path)
    segments = path.to_s.downcase.split('/').reject(&:empty?)
    return true if segments.first == 'fantasy'
    return true if segments[0, 2] == %w[mobile pages]
    return true if segments[0, 2] == %w[admin push]
    return true if segments.first == 'api' && %w[mlb nfl].include?(segments[1]) &&
      (segments & %w[contests tickets pools questions timer_states answers rosters scoresheets squads league_picks]).any?
    return true if segments.first == 'api' &&
      (segments & %w[contests tickets pools questions timer_states answers rosters scoresheets squads league_picks]).any?
    return true if segments.first == 'admin' && %w[mlb nfl].include?(segments[1]) &&
      (segments & %w[contests pools questions topics]).any?

    false
  end

  def self.reject!
    raise RetiredFeature, MESSAGE
  end

  class RetiredFeature < StandardError; end

  def initialize(app)
    @app = app
  end

  def call(env)
    if self.class.retired_path?(env['PATH_INFO'])
      return [410, { 'Content-Type' => 'text/plain; charset=utf-8',
                     'Cache-Control' => 'no-store' }, [MESSAGE]]
    end
    @app.call(env)
  end
end