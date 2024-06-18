class Calificacion
  attr_reader :id_telegram, :id_contenido, :puntaje

  def initialize(id_telegram, id_contenido, puntaje)
    raise ErrorAlInstanciarCalificacionPuntajeInvalido unless es_el_puntaje_valido?(puntaje.to_i)

    @id_telegram = id_telegram.to_i
    @id_contenido = id_contenido.to_i
    @puntaje = puntaje.to_i
  end

  def recalificar(puntaje_nuevo)
    raise ErrorAlInstanciarCalificacionPuntajeInvalido unless es_el_puntaje_valido?(puntaje_nuevo.to_i)

    puntaje_anterior = @puntaje
    @puntaje = puntaje_nuevo.to_i
    puntaje_anterior
  end

  private

  def es_el_puntaje_valido?(puntaje)
    puntaje.positive? && puntaje < 6
  end
end

class ErrorAlInstanciarCalificacionPuntajeInvalido < ArgumentError
  MSG_DE_ERROR = 'Error: calificacion invalida'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end
