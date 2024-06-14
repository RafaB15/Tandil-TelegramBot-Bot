require 'faraday'

class ConectorApi
  attr_reader :estado, :cuerpo

  API_REST_URL = ENV['API_URL']

  def initialize
    @estado = 0
    @cuerpo = nil
  end

  def obtener_version
    response = Faraday.get("#{API_REST_URL}/version")
    json_response = JSON.parse(response.body)

    json_response['version']
  end

  def crear_usuario(email, id_telegram)
    body = { email:, id_telegram: }

    respuesta = Faraday.post("#{API_REST_URL}/usuarios", body.to_json, 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  def obtener_contenidos_mas_vistas
    respuesta = Faraday.get("#{API_REST_URL}/visualizacion/top", 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  def buscar_contenido_por_titulo(titulo)
    respuesta = Faraday.get("#{API_REST_URL}/contenido", titulo:, 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  def calificar_contenido(id_telegram, id_contenido, calificacion)
    body = { id_telegram:, id_pelicula: id_contenido, calificacion: }

    respuesta = Faraday.post("#{API_REST_URL}/calificacion", body.to_json, 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  def marcar_favorita(id_telegram, id_contenido)
    body = { id_telegram:, id_contenido: }

    respuesta = Faraday.post("#{API_REST_URL}/favorito", body.to_json, 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  def obtener_favoritos(id_telegram)
    respuesta = Faraday.get("#{API_REST_URL}/favoritos", id_telegram:, 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  def obtener_sugerencias
    respuesta = Faraday.get("#{API_REST_URL}/contenidos/ultimos-agregados", 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  def obtener_detalles_de_contenido(id_contenido, id_telegram)
    respuesta = Faraday.get("#{API_REST_URL}/contenidos/#{id_contenido}/detalles", id_telegram:, 'Content-Type' => 'application/json')

    guardar_respuesta_api(respuesta)
  end

  private

  def guardar_respuesta_api(respuesta)
    @cuerpo = JSON.parse(respuesta.body)
    @estado = respuesta.status
  end
end
