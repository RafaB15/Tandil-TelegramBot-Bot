require 'faraday'

class ConectorApi
  attr_reader :estado, :respuesta

  def initialize
    @api_url = ENV['API_URL']
    @estado = 0
    @respuesta = nil
  end

  def obtener_version
    response = Faraday.get("#{@api_url}/version")
    json_response = JSON.parse(response.body)

    json_response['version']
  end

  def crear_usuario(email, telegram_id)
    body = { email:, telegram_id: }
    response = Faraday.post("#{@api_url}/usuarios", body.to_json, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end
end
