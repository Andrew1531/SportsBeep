module ApplicationHelper

  MULTI_WORD_MASCOTS = [
    'Red Sox', 'White Sox', 'Blue Jays', 'Trail Blazers',
    'Blue Jackets', 'Maple Leafs', 'Red Wings', 'Red Bulls',
    'Timber Wolves', 'Thunder Cats'
  ].freeze

  TEAM_COLORS = {
    'Arizona Diamondbacks' => ['#A71930', '#E3D4AD'],
    'Atlanta Braves' => ['#CE1141', '#13274F'],
    'Baltimore Orioles' => ['#DF4601', '#27251F'],
    'Boston Red Sox' => ['#BD3039', '#0C2340'],
    'Chicago Cubs' => ['#0E3386', '#CC3433'],
    'Chicago White Sox' => ['#27251F', '#C4CED4'],
    'Cincinnati Reds' => ['#C6011F', '#000000'],
    'Cleveland Guardians' => ['#00385D', '#E31937'],
    'Colorado Rockies' => ['#33006F', '#C4CED4'],
    'Detroit Tigers' => ['#0C2340', '#FA4616'],
    'Houston Astros' => ['#002D62', '#EB6E1F'],
    'Kansas City Royals' => ['#004687', '#BD9B60'],
    'Los Angeles Angels' => ['#BA0021', '#003263'],
    'Los Angeles Dodgers' => ['#005A9C', '#EF3E42'],
    'Miami Marlins' => ['#00A3E0', '#EF3340'],
    'Milwaukee Brewers' => ['#FFC52F', '#12284B'],
    'Minnesota Twins' => ['#002B5C', '#D31145'],
    'New York Mets' => ['#002D72', '#FF5910'],
    'New York Yankees' => ['#003087', '#C4CED4'],
    'Oakland Athletics' => ['#003831', '#EFB21E'],
    'Philadelphia Phillies' => ['#E81828', '#002D72'],
    'Pittsburgh Pirates' => ['#27251F', '#FDB827'],
    'San Diego Padres' => ['#2F241D', '#FFC425'],
    'San Francisco Giants' => ['#FD5A1E', '#27251F'],
    'Seattle Mariners' => ['#0C2C56', '#005C5C'],
    'St. Louis Cardinals' => ['#C41E3A', '#0C2340'],
    'Tampa Bay Rays' => ['#092C5C', '#8FBCE6'],
    'Texas Rangers' => ['#003278', '#C0111F'],
    'Toronto Blue Jays' => ['#134A8E', '#1D2D5C'],
    'Washington Nationals' => ['#AB0003', '#14225A'],

    'Arizona Cardinals' => ['#97233F', '#000000'],
    'Atlanta Falcons' => ['#A71930', '#000000'],
    'Baltimore Ravens' => ['#241773', '#000000'],
    'Buffalo Bills' => ['#00338D', '#C60C30'],
    'Carolina Panthers' => ['#0085CA', '#101820'],
    'Chicago Bears' => ['#0B162A', '#C83803'],
    'Cincinnati Bengals' => ['#FB4F14', '#000000'],
    'Cleveland Browns' => ['#311D00', '#FF3C00'],
    'Dallas Cowboys' => ['#003594', '#869397'],
    'Denver Broncos' => ['#FB4F14', '#002244'],
    'Detroit Lions' => ['#0076B6', '#B0B7BC'],
    'Green Bay Packers' => ['#203731', '#FFB612'],
    'Houston Texans' => ['#03202F', '#A71930'],
    'Indianapolis Colts' => ['#002C5F', '#A2AAAD'],
    'Jacksonville Jaguars' => ['#006778', '#9F792C'],
    'Kansas City Chiefs' => ['#E31837', '#FFB81C'],
    'Las Vegas Raiders' => ['#000000', '#A5ACAF'],
    'Los Angeles Chargers' => ['#0080C6', '#FFC20E'],
    'Los Angeles Rams' => ['#003594', '#FFA300'],
    'Miami Dolphins' => ['#008E97', '#FC4C02'],
    'Minnesota Vikings' => ['#4F2683', '#FFC62F'],
    'New England Patriots' => ['#002244', '#C60C30'],
    'New Orleans Saints' => ['#D3BC8D', '#101820'],
    'New York Giants' => ['#0B2265', '#A71930'],
    'New York Jets' => ['#125740', '#000000'],
    'Philadelphia Eagles' => ['#004C54', '#A5ACAF'],
    'Pittsburgh Steelers' => ['#FFB612', '#101820'],
    'San Francisco 49ers' => ['#AA0000', '#B3995D'],
    'Seattle Seahawks' => ['#002244', '#69BE28'],
    'Tampa Bay Buccaneers' => ['#D50A0A', '#34302B'],
    'Tennessee Titans' => ['#0C2340', '#4B92DB'],
    'Washington Commanders' => ['#5A1414', '#FFB612'],

    'Atlanta Hawks' => ['#E03A3E', '#C1D32F'],
    'Boston Celtics' => ['#007A33', '#BA9653'],
    'Brooklyn Nets' => ['#000000', '#FFFFFF'],
    'Charlotte Hornets' => ['#1D1160', '#00788C'],
    'Chicago Bulls' => ['#CE1141', '#000000'],
    'Cleveland Cavaliers' => ['#860038', '#FDBB30'],
    'Dallas Mavericks' => ['#00538C', '#B8C4CA'],
    'Denver Nuggets' => ['#0E2240', '#FEC524'],
    'Detroit Pistons' => ['#C8102E', '#1D42BA'],
    'Golden State Warriors' => ['#1D428A', '#FFC72C'],
    'Houston Rockets' => ['#CE1141', '#000000'],
    'Indiana Pacers' => ['#002D62', '#FDBB30'],
    'LA Clippers' => ['#C8102E', '#1D428A'],
    'Los Angeles Lakers' => ['#552583', '#FDB927'],
    'Memphis Grizzlies' => ['#5D76A9', '#12173F'],
    'Miami Heat' => ['#98002E', '#F9A01B'],
    'Milwaukee Bucks' => ['#00471B', '#EEE1C6'],
    'Minnesota Timberwolves' => ['#0C2340', '#236192'],
    'New Orleans Pelicans' => ['#0C2340', '#C8102E'],
    'New York Knicks' => ['#006BB6', '#F58426'],
    'Oklahoma City Thunder' => ['#007AC1', '#EF6C00'],
    'Orlando Magic' => ['#0077C0', '#C4CED4'],
    'Philadelphia 76ers' => ['#006BB6', '#ED174C'],
    'Phoenix Suns' => ['#1D1160', '#E56020'],
    'Portland Trail Blazers' => ['#E03A3E', '#000000'],
    'Sacramento Kings' => ['#5A2D81', '#63727A'],
    'San Antonio Spurs' => ['#C4CED4', '#000000'],
    'Toronto Raptors' => ['#CE1141', '#000000'],
    'Utah Jazz' => ['#002B5C', '#00471B'],
    'Washington Wizards' => ['#002B5C', '#E31837'],

    'Anaheim Ducks' => ['#F47A38', '#B9975B'],
    'Arizona Coyotes' => ['#8C2633', '#E2D6B5'],
    'Boston Bruins' => ['#FFB81C', '#000000'],
    'Buffalo Sabres' => ['#002654', '#FCB514'],
    'Calgary Flames' => ['#D2001C', '#FAAF19'],
    'Carolina Hurricanes' => ['#CC0000', '#000000'],
    'Chicago Blackhawks' => ['#CF0A2C', '#000000'],
    'Colorado Avalanche' => ['#6F263D', '#236192'],
    'Columbus Blue Jackets' => ['#002654', '#CE1141'],
    'Dallas Stars' => ['#006847', '#8F8F8C'],
    'Detroit Red Wings' => ['#CE1141', '#FFFFFF'],
    'Edmonton Oilers' => ['#041E42', '#FF4C00'],
    'Florida Panthers' => ['#041E42', '#C8102E'],
    'Los Angeles Kings' => ['#111111', '#A2AAAD'],
    'Minnesota Wild' => ['#154734', '#A6192E'],
    'Montreal Canadiens' => ['#AF1E2D', '#192168'],
    'Nashville Predators' => ['#FFB81C', '#041E42'],
    'New Jersey Devils' => ['#CE1141', '#000000'],
    'New York Islanders' => ['#00539B', '#F47D30'],
    'New York Rangers' => ['#0038A8', '#CE1141'],
    'Ottawa Senators' => ['#C52032', '#C2912C'],
    'Philadelphia Flyers' => ['#F74902', '#000000'],
    'Pittsburgh Penguins' => ['#000000', '#CFC493'],
    'San Jose Sharks' => ['#006D75', '#EA7200'],
    'Seattle Kraken' => ['#001628', '#99D9D9'],
    'St. Louis Blues' => ['#002F87', '#FCB514'],
    'Tampa Bay Lightning' => ['#002868', '#FFFFFF'],
    'Toronto Maple Leafs' => ['#00205B', '#FFFFFF'],
    'Vancouver Canucks' => ['#00205B', '#00843D'],
    'Vegas Golden Knights' => ['#B4975A', '#333F48'],
    'Washington Capitals' => ['#C8102E', '#041E42'],
    'Winnipeg Jets' => ['#041E42', '#004C97'],
  }.freeze

  def split_team_name(full_name)
    return ['', full_name || ''] if full_name.blank?
    MULTI_WORD_MASCOTS.each do |mascot|
      if full_name.end_with?(mascot)
        city = full_name[0...(full_name.length - mascot.length)].strip
        return [city, mascot]
      end
    end
    parts = full_name.split(' ')
    if parts.length > 1
      [parts[0...-1].join(' '), parts.last]
    else
      ['', full_name]
    end
  end

  def team_color(team_name, index = 0)
    colors = TEAM_COLORS[team_name]
    return colors[index] if colors
    index == 0 ? '#3767ab' : '#4d5c7d'
  end

  def cache_key_for(relation, query = :all)
    count = relation.count
    max_updated_at = relation.maximum(:updated_at).try(:to_i)
    "#{relation.model}/#{query}-#{count}-#{max_updated_at}"
  end

  def timestamp(datetime)
    datetime.utc.iso8601
  end

  def est(datetime)
    datetime.in_time_zone('Eastern Time (US & Canada)')
  end

  def glyphicon(icon)
    content_tag(:span, '', class: "glyphicon glyphicon-#{icon}")
  end

  def create_or_update_text(record)
    (record.persisted?) ? 'Update' : 'Create'
  end

end
