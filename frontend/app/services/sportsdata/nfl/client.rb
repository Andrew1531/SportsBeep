module SportsData
  module Nfl
    module Client
      extend ActiveSupport::Concern

      def get(url)
        response = client.get url
        JSON.parse(response.body).tap do |json|
          yield json if block_given?
        end
      end

      def client
        @client ||= Faraday.new(url: ENV['NFL_SPORTSDATA_URL'], params: { api_key: ENV['NFL_SPORTSDATA_TOKEN'] }) do |http|
          http.request :url_encoded
          http.adapter :net_http
        end
      end

      def year
        @_year ||= ENV['NFL_YEAR'] || Time.current.year
      end

      def season
        @_season ||= ENV['NFL_SEASON'] || 'REG'
      end

    end
  end
end