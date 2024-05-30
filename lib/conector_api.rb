require 'faraday'

class ConectorApi

  def obtener_version()
    api_url = ENV['API_URL_DOCKER_LOCAL']
    response = Faraday.get(api_url + '/version')
    json_response = JSON.parse(response.body) # Checkear si devolvio 201, etc

    json_response['version']
  end

end