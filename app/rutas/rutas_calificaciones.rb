require_relative 'utiles'

module RutasCalificaciones
  include Routing

  COMANDO_CALIFICAR_CONTENIDO = %r{/calificar (?<id_contenido>\d+) (?<puntaje>-?\d+)}

  RESPUESTA_EXITO_AL_CALIFICAR_CONTENIDO = 'Calificacion registrada exitosamente'.freeze
  RESPUESTA_RECALIFICAR_CONTENIDO = '¡Has cambiado de opinion, tu recalificacion fue actualizada!'.freeze

  on_message_pattern COMANDO_CALIFICAR_CONTENIDO do |bot, message, args|
    id_telegram = message.from.id.to_i
    id_contenido = args['id_contenido'].to_i
    puntaje = args['puntaje']

    conector_api = ConectorApi.new

    plataforma = Plataforma.new(conector_api)

    begin
      puntaje_anterior = plataforma.calificar_contenido(id_telegram, id_contenido, puntaje)

      text = if puntaje_anterior.nil?
               RESPUESTA_EXITO_AL_CALIFICAR_CONTENIDO
             else
               RESPUESTA_RECALIFICAR_CONTENIDO
             end
    rescue StandardError => e
      text = manejar_error(e)
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
