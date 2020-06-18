module RequestsHandler

  def parse_response(json)
    JSON.parse(json)
  end

  def basic_connection
    Faraday.new(url: ENV['WAMPI_URL']) do |f|
      f.adapter :net_http
    end
  end
end
