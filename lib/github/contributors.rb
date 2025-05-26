require "net/http"

module Github
  REPO = "stakkd-tv/stakkd"

  class Contributors
    class << self
      def all = @@contributors ||= get_contributors

      private

      def get_contributors
        uri = URI("https://api.github.com/repos/#{Github::REPO}/contributors")
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new uri

        response = https.request(request)
        puts response
        response.is_a?(Net::HTTPOK) ? JSON.parse(response.body, symbolize_names: true) : []
      end
    end
  end
end
