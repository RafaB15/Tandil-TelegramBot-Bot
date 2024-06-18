require_relative 'utiles'

module RutasCalificaciones
  include Routing

  COMANDO_CALIFICAR_CONTENIDO = %r{/calificar (?<id_contenido>\d+) (?<puntaje>-?\d+)}

  RESPUESTA_EXITO_AL_CALIFICAR_CONTENIDO = 'Calificacion registrada exitosamente'.freeze
  RESPUESTA_ERROR_DEBE_ESTAR_VISTO_EL_CONTENIDO_AL_CALIFICAR_CONTENIDO = '¡Aún no viste este contenido, miralo para poder calificarlo!'.freeze
  RESPUESTA_RECALIFICAR_CONTENIDO = '¡Has cambiado de opinion, tu recalificacion fue actualizada!'.freeze
  RESPUESTA_CONTENIDO_INEXISTENTE = 'El contenido ingresado no existe'.freeze
  RESPUESTA_ERROR_CALIFICACION_INVALIDA = 'La calificacion es del 1 al 5. ¡Volve a calificar!'.freeze
  RESPUESTA_ERROR_CREACION_CALIFICACION = 'Error al calificar la película. Inténtalo de nuevo más tarde.'.freeze
  RESPUESTA_ERROR_PREDETERMINADO_AL_CALIFICAR_CONTENIDO = 'Error al calificar la película. Inténtalo de nuevo más tarde.'.freeze

  on_message_pattern COMANDO_CALIFICAR_CONTENIDO do |bot, message, args|
    id_contenido = args['id_contenido'].to_i
    puntaje = args['puntaje'].to_i
    id_telegram = message.from.id.to_i

    respuesta = ConectorApi.new.calificar_contenido(id_telegram, id_contenido, puntaje)

    estado = respuesta.status
    cuerpo = JSON.parse(respuesta.body)

    text = case estado
           when 201
             RESPUESTA_EXITO_AL_CALIFICAR_CONTENIDO
           when 200
             RESPUESTA_RECALIFICAR_CONTENIDO
           when 422
             if cuerpo['details']['field'] == 'visualizacion'
               RESPUESTA_ERROR_DEBE_ESTAR_VISTO_EL_CONTENIDO_AL_CALIFICAR_CONTENIDO
             elsif cuerpo['details']['field'] == 'calificacion'
               RESPUESTA_ERROR_CALIFICACION_INVALIDA
             else
               RESPUESTA_ERROR_CREACION_CALIFICACION
             end
           when 404
             RESPUESTA_CONTENIDO_INEXISTENTE
           else
             RESPUESTA_ERROR_PREDETERMINADO_AL_CALIFICAR_CONTENIDO
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
