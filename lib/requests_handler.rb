module RequestsHandler

  def parse_response(json)
    JSON.parse(json)
  end
end
