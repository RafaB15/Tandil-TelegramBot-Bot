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

    @conector_api.calificar_contenido(calificacion)
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
end
