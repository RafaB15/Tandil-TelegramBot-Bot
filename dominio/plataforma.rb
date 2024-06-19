Dir[File.join(__dir__, '*.rb')].each { |file| require file }

class Plataforma
  def initialize(conector_api)
    @conector_api = conector_api
  end

  def registrar_usuario(email, id_telegram)
    usuario = Usuario.new(email, id_telegram)

    respuesta = @conector_api.registrar_usuario(usuario)

    estado = respuesta.status
    cuerpo = JSON.parse(respuesta.body)

    return if estado == 201

    if estado == 409
      if cuerpo['details']['field'] == 'id_telegram'
        raise ErrorIDTelegramYaAsociadoAUnaCuentaExistenteEnLaAPI
      else
        raise ErrorEmailYaAsociadoAUnaCuentaExistenteEnLaAPI
      end
    end

    raise IOError
  end

  def calificar_contenido(id_telegram, id_contenido, puntaje)
    calificacion = Calificacion.new(id_telegram, id_contenido, puntaje)

    respuesta = @conector_api.calificar_contenido(calificacion)

    estado = respuesta.status
    cuerpo = JSON.parse(respuesta.body)

    if estado == 200
      puntaje_anterior = cuerpo['puntaje_anterior']
      calificacion.recalificar(puntaje_anterior)

      return calificacion
    end

    return if estado == 201

    manejar_respuesta_calificar_contenido(estado, cuerpo)
  end

  def marcar_contenido_como_favorito(id_telegram, id_contenido)
    favorito = Favorito.new(id_telegram, id_contenido)

    respuesta = @conector_api.marcar_contenido_como_favorito(favorito)

    estado = respuesta.status

    return if estado == 201

    raise IOError
  end

  def obtener_favoritos(id_telegram)
    respuesta = @conector_api.obtener_favoritos(id_telegram)

    favoritos = JSON.parse(respuesta.body)

    raise IOError if favoritos.empty?

    favoritos
  end

  def buscar_contenido_por_titulo(titulo)
    respuesta = @conector_api.buscar_contenido_por_titulo(titulo)

    contenidos = JSON.parse(respuesta.body)

    raise IOError if contenidos.empty?

    contenidos
  end

  def obtener_mas_vistos
    respuesta = @conector_api.obtener_sugerencias_contenidos_mas_vistos

    sugerencias_mas_vistos = JSON.parse(respuesta.body)

    raise IOError if sugerencias_mas_vistos.empty?

    sugerencias_mas_vistos
  end

  def obtener_mas_nuevos
    respuesta = @conector_api.obtener_sugerencias_contenidos_mas_nuevos

    sugerencias_mas_nuevos = JSON.parse(respuesta.body)

    raise IOError if sugerencias_mas_nuevos.empty?

    sugerencias_mas_nuevos
  end

  private

  def manejar_respuesta_calificar_contenido(estado, cuerpo)
    case estado
    when 422
      case cuerpo['details']['field']
      when 'visualizacion'
        raise ErrorAlCalificarContenidoNoVistoPorUsuarioDeTelegram
      when 'calificacion'
        raise ErrorAlInstanciarCalificacionPuntajeInvalido
      when 'visualizacion_de_capitulo'
        raise ErrorAlCalificarTemporadaSinSuficientesCapitulosVistosPorUsuarioDeTelegram
      end
    when 404
      raise ErrorContenidoInexistenteEnAPI if cuerpo['details']['field'] == 'contenido'
    end

    raise IOError
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

class ErrorAlCalificarContenidoNoVistoPorUsuarioDeTelegram < IOError
  MSG_DE_ERROR = 'Error: el usuario de telegram no tiene el contenido visto al calificar el contenido'.freeze

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

class ErrorAlCalificarTemporadaSinSuficientesCapitulosVistosPorUsuarioDeTelegram < IOError
  MSG_DE_ERROR = 'Error: el usuario de telegram no tiene suficientes capitulos vistos al calificar la temporada'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end

# Error marcar como favorito
# ==============================================================================

class ErrorAlMarcarComoFavoritoContenidoNoVistoPorUsuarioDeTelegram < IOError
  MSG_DE_ERROR = 'Error: el usuario de telegram no tiene el contenido visto al marcar como favorito el contenido'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end
