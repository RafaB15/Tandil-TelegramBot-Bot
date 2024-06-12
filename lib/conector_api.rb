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
    response = Faraday.get("#{@api_url}/visualizacion/top", 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def buscar_pelicula_por_titulo(titulo)
    response = Faraday.get("#{@api_url}/contenido", titulo:, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def calificar_contenido(id_telegram, id_pelicula, calificacion)
    body = { id_telegram:, id_pelicula:, calificacion: }

    response = Faraday.post("#{@api_url}/calificacion", body.to_json, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def marcar_favorita(id_telegram, id_contenido)
    body = { id_telegram:, id_contenido: }
    response = Faraday.post("#{@api_url}/favorito", body.to_json, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def obtener_favoritos(id_telegram)
    response = Faraday.get("#{@api_url}/favoritos", id_telegram:, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def obtener_sugerencias
    response = Faraday.get("#{@api_url}/contenidos/ultimos-agregados", 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end

  def obtener_detalles_de_pelicula(id_pelicula, id_telegram)
    response = Faraday.get("#{@api_url}/contenidos/#{id_pelicula}/detalles", id_telegram:, 'Content-Type' => 'application/json')
    @respuesta = JSON.parse(response.body)
    @estado = response.status
  end
end
