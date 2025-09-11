RailsAdmin.config do |config|

  # Devise integration
  config.authenticate_with do
    warden.authenticate! scope: :administrator
  end
  config.current_user_method(&:current_administrator)

  Rails.application.eager_load!
  config.included_models = %w[
    GlAccount
    Account
    Administrator
    Question
    Contest
    ContestTemplate
    ContestTemplateQuestion
    Game
    GameLeaguePick
    GamePool
    Player
    Stat
    StatTopic
    Team
    Ticket
    Pool
    QuestionAnswer
    RecentStat
    SeasonalStat
    TeamStat
    TicketPlayer
    PromoCode
    User
    BestQuestion
    BustQuestion
    Mlb::Question
    Nfl::Question
    Mlb::Contest
    Nfl::Contest
    Mlb::Game
    Nfl::Game
    Mlb::Player
    Nfl::Player
    Mlb::Stat
    Nfl::Stat
    Mlb::StatTopic
    Nfl::StatTopic
    Mlb::Team
    Nfl::Team
    Mlb::Ticket
    Nfl::Ticket
  ]

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    show
  end
end
