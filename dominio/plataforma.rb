Dir[File.join(__dir__, '*.rb')].each { |file| require file }

class Plataforma
  def initialize(conector_api)
    @conector_api = conector_api
  end

  def registrar_usuario(email, id_telegram)
    usuario = Usuario.new(email, id_telegram)

    @conector_api.registrar_usuario(usuario)
  end

  def calificar_contenido(id_telegram, id_contenido, puntaje)
    calificacion = Calificacion.new(id_telegram, id_contenido, puntaje)

    @conector_api.calificar_contenido(calificacion)
  end
end
