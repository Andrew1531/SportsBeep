module SportsData
  module Mlb
    module Images
      module Client
        extend ActiveSupport::Concern
        include SportsData::Mlb::Client

        def client
          @client ||= Faraday.new(url: ENV['MLB_IMAGES_SPORTSDATA_URL'], params: { api_key: ENV['MLB_IMAGES_SPORTSDATA_TOKEN'] }) do |http|
            http.request :url_encoded
            http.adapter :net_http
          end
        end

      end
    end
  end
end