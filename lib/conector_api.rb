require 'faraday'

class ConectorApi
  API_REST_URL = ENV['API_URL']

  def obtener_version
    Faraday.get("#{API_REST_URL}/version")
  end

  def registrar_usuario(usuario)
    cuerpo = { email: usuario.email, id_telegram: usuario.id_telegram }

    respuesta = Faraday.post("#{API_REST_URL}/usuarios", cuerpo.to_json, 'Content-Type' => 'application/json')

    estado = respuesta.status
    cuerpo = JSON.parse(respuesta.body)

    return if estado == 201

    if estado == 409
      if cuerpo['details']['field'] == 'id_telegram'
        raise ErrorIDTelegramYaAsociadoAUnaCuentaExistenteEnLaAPI
      else
        raise ErrorEmailYaAsociadoAUnaCuentaExistenteEnLaAPI
      end
    else
      raise IOError
    end
  end

  def calificar_contenido(calificacion)
    cuerpo = { id_telegram: calificacion.id_telegram, id_contenido: calificacion.id_contenido, puntaje: calificacion.puntaje }

    respuesta = Faraday.post("#{API_REST_URL}/calificaciones", cuerpo.to_json, 'Content-Type' => 'application/json')

    estado = respuesta.status
    cuerpo = JSON.parse(respuesta.body)

    if estado == 200
      puntaje_anterior = cuerpo['puntaje_anterior']
      calificacion.recalificar(puntaje_anterior)

      return calificacion
    end

    manejar_respuesta_calificar_contenido(estado, cuerpo)
  end

  def marcar_contenido_como_favorito(id_telegram, id_contenido)
    cuerpo = { id_telegram:, id_contenido: }

    Faraday.post("#{API_REST_URL}/favoritos", cuerpo.to_json, 'Content-Type' => 'application/json')
  end

  def obtener_favoritos(id_telegram)
    Faraday.get("#{API_REST_URL}/favoritos", id_telegram:, 'Content-Type' => 'application/json')
  end

  def obtener_sugerencias_contenidos_mas_nuevos
    Faraday.get("#{API_REST_URL}/contenidos/ultimos-agregados", 'Content-Type' => 'application/json')
  end

  def obtener_sugerencias_contenidos_mas_vistos
    Faraday.get("#{API_REST_URL}/visualizaciones/top", 'Content-Type' => 'application/json')
  end

  def buscar_contenido_por_titulo(titulo)
    Faraday.get("#{API_REST_URL}/contenidos", titulo:, 'Content-Type' => 'application/json')
  end

  def obtener_detalles_de_contenido(id_contenido, id_telegram)
    Faraday.get("#{API_REST_URL}/contenidos/#{id_contenido}/detalles", id_telegram:, 'Content-Type' => 'application/json')
  end

  private

  def manejar_respuesta_calificar_contenido(estado, cuerpo)
    case estado
    when 201
      nil
    when 422
      if cuerpo['details']['field'] == 'visualizacion'
        raise ErrorAlPedirCalificacionContenidoNoVistoPorUsuarioDeTelegram
      elsif cuerpo['details']['field'] == 'calificacion'
        raise ErrorAlInstanciarCalificacionPuntajeInvalido
      else
        raise IOError
      end
    when 404
      raise ErrorContenidoInexistenteEnAPI
    else
      raise IOError
    end
  end
end

# Error registrar usuario
# ==============================================================================

class ErrorIDTelegramYaAsociadoAUnaCuentaExistenteEnLaAPI < IOError
  MSG_DE_ERROR = 'Error: email ya asociado a una cuenta existente en la API'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end

class ErrorEmailYaAsociadoAUnaCuentaExistenteEnLaAPI < IOError
  MSG_DE_ERROR = 'Error: ID telegram ya asociado a una cuenta existente en la API'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end

# Error calificar
# ==============================================================================

class ErrorAlPedirCalificacionContenidoNoVistoPorUsuarioDeTelegram < IOError
  MSG_DE_ERROR = 'Error: el usuario de telegram no tiene el contenido visto'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end

class ErrorContenidoInexistenteEnAPI < IOError
  MSG_DE_ERROR = 'Error: contenido no existente en la base de datos de la API Rest'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end
