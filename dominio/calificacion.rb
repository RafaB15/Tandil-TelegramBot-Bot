class Calificacion
  attr_reader :id_telegram, :id_contenido, :puntaje

  def initialize(id_telegram, id_contenido, puntaje)
    raise ErrorAlInstanciarCalificacionInvalida unless es_el_puntaje_valido?(puntaje)

    @id_telegram = id_telegram
    @id_contenido = id_contenido
    @puntaje = puntaje
  end

  private

  def es_el_puntaje_valido?(puntaje)
    puntaje.positive? && puntaje < 6
  end
end

class ErrorAlInstanciarCalificacionInvalida < ArgumentError
  MSG_DE_ERROR = 'Error: calificacion invalida'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end
