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

    manejar_respuesta_calificar_contenido(estado, cuerpo)
  end

  def marcar_contenido_como_favorito(id_telegram, id_contenido)
    favorito = Favorito.new(id_telegram, id_contenido)

    respuesta = @conector_api.marcar_contenido_como_favorito(favorito)

    estado = respuesta.status

    raise IOError if estado != 201
  end

  def obtener_favoritos(id_telegram)
    respuesta = @conector_api.obtener_favoritos(id_telegram)

    favoritos = JSON.parse(respuesta.body)

    raise IOError if favoritos.empty?

    favoritos
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
