require_relative 'utiles'
require 'logger'

module RutasCalificaciones
  include Routing

  COMANDO_CALIFICAR_CONTENIDO = %r{/calificar (?<id_contenido>\d+) (?<puntaje>-?\d+)}

  RESPUESTA_EXITO_AL_CALIFICAR_CONTENIDO = 'Calificacion registrada exitosamente'.freeze
  RESPUESTA_RECALIFICAR_CONTENIDO = '¡Has cambiado de opinion, tu recalificacion fue actualizada!'.freeze

  MAPA_DE_ERRORES_CALIFICAR = {
    'ErrorAlCalificarContenidoNoVistoPorUsuarioDeTelegram' => '¡Aún no viste este contenido, miralo para poder calificarlo!',
    'ErrorAlInstanciarCalificacionPuntajeInvalido' => 'La calificacion es del 1 al 5. ¡Volve a calificar!',
    'ErrorContenidoInexistenteEnAPI' => 'El contenido ingresado no existe',
    'ErrorAlCalificarTemporadaSinSuficientesCapitulosVistosPorUsuarioDeTelegram' => '¡No tenés suficientes capítulos diferentes vistos de esta Temporada para poder calificarla!',
    'ErrorPredeterminado' => 'Error al calificar el contenido. Inténtalo de nuevo más tarde.'
  }.freeze

  on_message_pattern COMANDO_CALIFICAR_CONTENIDO do |bot, message, args, logger|
    id_telegram = message.from.id
    id_contenido = args['id_contenido']
    puntaje = args['puntaje']

    logger.debug "[BOT] /calificar id_contenido: #{id_contenido} - puntaje: #{puntaje}"

    conector_api = ConectorApi.new(logger)

    plataforma = Plataforma.new(conector_api)

    begin
      calificacion_anterior = plataforma.calificar_contenido(id_telegram, id_contenido, puntaje)

      text = if calificacion_anterior.nil?
               RESPUESTA_EXITO_AL_CALIFICAR_CONTENIDO
             else
               RESPUESTA_RECALIFICAR_CONTENIDO
             end
    rescue StandardError => e
      text = manejar_error(MAPA_DE_ERRORES_CALIFICAR, e)
    end

    logger.debug "[BOT] Respuesta: #{text}"

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
