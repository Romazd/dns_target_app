require 'net/http'
require 'uri'
require 'json'
require 'zlib'
require 'stringio'

class HerokuConnection

  def self.call
    uri = URI("https://api.heroku.com/apps/dns-target-app/domains")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{Rails.application.credentials.dig(:heroku_secret, :secret)}"
    request["Accept"] = "application/vnd.heroku+json; version=3"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response['content-encoding'] == 'gzip'
      sio = StringIO.new(response.body)
      gz = Zlib::GzipReader.new(sio)
      body = gz.read
    else
      body = response.body
    end
    Rails.logger.info("Response: #{response.code} #{response.message} - #{response.body}")
    dns_targets = JSON.parse(body)
    dns_target = dns_targets.first['hostname'] # Simplified; you might need to adjust based on actual response

    return dns_target
  rescue => e
    return { error: e.message }
  end
end