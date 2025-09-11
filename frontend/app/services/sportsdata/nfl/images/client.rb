module SportsData
  module Nfl
    module Images
      module Client
        extend ActiveSupport::Concern

        def get(url)
          response = client.get url
          XML.new(response.body)
        end

        def xml(node)
          XML.new(node)
        end

        def client
          @client ||= Faraday.new(url: ENV['NFL_IMAGES_SPORTSDATA_URL'], params: { api_key: ENV['NFL_IMAGES_SPORTSDATA_TOKEN'] }) do |http|
            http.request :url_encoded
            http.adapter :net_http
          end
        end

      end
    end
  end
end