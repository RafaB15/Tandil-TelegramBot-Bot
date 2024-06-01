require 'faraday'

class ConectorApi
  def initialize
    @api_url = ENV['API_URL']
  end

  def obtener_version
    response = Faraday.get("#{@api_url}/version")
    json_response = JSON.parse(response.body) # Checkear si devolvio 201, etc

    json_response['version']
  end

  def crear_usuario(email, telegram_id)
    body = { email:, telegram_id: }.to_json
    response = Faraday.post("#{@api_url}/usuarios", body, 'Content-Type' => 'application/json')
    response.status
  end
end
