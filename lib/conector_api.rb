require 'faraday'

class ConectorApi
  API_REST_URL = ENV['API_URL']

  def initialize(logger = nil)
    @logger = logger
  end

  def obtener_version
    @logger&.debug '[GET] /version'

    respuesta = Faraday.get("#{API_REST_URL}/version")

    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def registrar_usuario(usuario)
    cuerpo = { email: usuario.email, id_telegram: usuario.id_telegram }

    @logger&.debug "[POST] /usuarios - Body: #{cuerpo.to_json}"

    respuesta = Faraday.post("#{API_REST_URL}/usuarios", cuerpo.to_json, 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def calificar_contenido(calificacion)
    cuerpo = { id_telegram: calificacion.id_telegram, id_contenido: calificacion.id_contenido, puntaje: calificacion.puntaje }

    @logger&.debug "[POST] /calificaciones - Body: #{cuerpo.to_json}"

    respuesta = Faraday.post("#{API_REST_URL}/calificaciones", cuerpo.to_json, 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def marcar_contenido_como_favorito(favorito)
    cuerpo = { id_telegram: favorito.id_telegram, id_contenido: favorito.id_contenido }

    @logger&.debug "[POST] /favoritos - Body: #{cuerpo.to_json}"

    respuesta = Faraday.post("#{API_REST_URL}/favoritos", cuerpo.to_json, 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def obtener_favoritos(id_telegram)
    @logger&.debug "[GET] /favoritos?id_telegram=#{id_telegram}"

    respuesta = Faraday.get("#{API_REST_URL}/favoritos", id_telegram:, 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def obtener_sugerencias_contenidos_mas_nuevos
    @logger&.debug '[GET] /contenidos/ultimos-agregados'

    respuesta = Faraday.get("#{API_REST_URL}/contenidos/ultimos-agregados", 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def obtener_sugerencias_contenidos_mas_vistos
    @logger&.debug '[GET] /visualizaciones/top'

    respuesta = Faraday.get("#{API_REST_URL}/visualizaciones/top", 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def buscar_contenido_por_titulo(titulo)
    @logger&.debug "[GET] /contenidos?titulo=#{titulo}"

    respuesta = Faraday.get("#{API_REST_URL}/contenidos", titulo:, 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end

  def obtener_detalles_de_contenido(id_contenido, id_telegram)
    @logger&.debug "[GET] /contenidos/#{id_contenido}/detalles?id_telegram=#{id_telegram}"

    respuesta = Faraday.get("#{API_REST_URL}/contenidos/#{id_contenido}/detalles", id_telegram:, 'Content-Type' => 'application/json')
    @logger&.debug "[BOT] Respuesta : [Estado] : #{respuesta.status} - [Cuerpo] : #{respuesta.body}"

    respuesta
  end
end
