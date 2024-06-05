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

  def crear_usuario(email, id_telegram)
    body = { email:, id_telegram: }
    response = Faraday.post("#{@api_url}/usuarios", body.to_json, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def obtener_peliculas_mas_vistas
    response = Faraday.get("#{@api_url}/visualizacion/top", 'Content-Type' => 'application/json').body
    JSON.parse(response)
  end

  def calificar_contenido(id_telegram, id_pelicula, calificacion)
    body = { id_telegram:, id_pelicula:, calificacion: }
    response = Faraday.post("#{@api_url}/calificacion", body.to_json, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def marcar_favorita(id_telegram, id_pelicula)
    body = { id_telegram:, id_pelicula: }
    response = Faraday.post("#{@api_url}/favorito", body.to_json, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end
end
