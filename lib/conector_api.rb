require 'faraday'

class ConectorApi
  API_REST_URL = ENV['API_URL']

  def obtener_version
    respuesta = Faraday.get("#{API_REST_URL}/version")
    respuesta_json = JSON.parse(respuesta.body)

    respuesta_json['version']
  end

  def crear_usuario(email, id_telegram)
    cuerpo = { email:, id_telegram: }

    respuesta = Faraday.post("#{API_REST_URL}/usuarios", cuerpo.to_json, 'Content-Type' => 'application/json')

    [respuesta.status, JSON.parse(respuesta.body)]
  end

  def calificar_contenido(id_telegram, id_contenido, puntaje)
    cuerpo = { id_telegram:, id_pelicula: id_contenido, puntaje: }

    respuesta = Faraday.post("#{API_REST_URL}/calificaciones", cuerpo.to_json, 'Content-Type' => 'application/json')

    respuesta.status
  end

  def marcar_contenido_como_favorito(id_telegram, id_contenido)
    cuerpo = { id_telegram:, id_contenido: }

    respuesta = Faraday.post("#{API_REST_URL}/favoritos", cuerpo.to_json, 'Content-Type' => 'application/json')

    respuesta.status
  end

  def obtener_favoritos(id_telegram)
    respuesta = Faraday.get("#{API_REST_URL}/favoritos", id_telegram:, 'Content-Type' => 'application/json')

    JSON.parse(respuesta.body)
  end

  def obtener_sugerencias_contenidos_mas_nuevos
    respuesta = Faraday.get("#{API_REST_URL}/contenidos/ultimos-agregados", 'Content-Type' => 'application/json')

    JSON.parse(respuesta.body)
  end

  def obtener_sugerencias_contenidos_mas_vistos
    respuesta = Faraday.get("#{API_REST_URL}/visualizaciones/top", 'Content-Type' => 'application/json')

    JSON.parse(respuesta.body)
  end

  def buscar_contenido_por_titulo(titulo)
    respuesta = Faraday.get("#{API_REST_URL}/contenidos", titulo:, 'Content-Type' => 'application/json')

    JSON.parse(respuesta.body)
  end

  def obtener_detalles_de_contenido(id_contenido, id_telegram)
    respuesta = Faraday.get("#{API_REST_URL}/contenidos/#{id_contenido}/detalles", id_telegram:, 'Content-Type' => 'application/json')

    [respuesta.status, JSON.parse(respuesta.body)]
  end
end
