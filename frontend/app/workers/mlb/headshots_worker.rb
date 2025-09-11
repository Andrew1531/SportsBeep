class Mlb::HeadshotsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include SportsData::Mlb::Images::Client

  recurrence { monthly.day_of_month(1, 15) }

  def perform
    get('usat/players/headshots/manifests/all_assets.xml').each('assetlist asset') do |xml|
      headshot_path = xml['links link href']
      Background.push DownloadHeadshotWorker, xml['player_id'], headshot_path
    end
  end

  # This class gets queued up by the main worker and downloads each individual image. This way
  # we can process all of the XML without waiting for the downloads, then the downloads can go at
  # their own pace in the queue
  class DownloadHeadshotWorker
    include Sidekiq::Worker

    def perform(player_id, headshot_path)
      if player = Player.find_by(external_id: player_id)
        player.update remote_headshot_url: to_url(headshot_path)
      end
    end

    def to_url(path)
      "#{ENV['MLB_IMAGES_SPORTSDATA_URL']}/usat#{path}?api_key=#{ENV['MLB_IMAGES_SPORTSDATA_TOKEN']}"
    end
  end

end