require_relative 'utiles'

module RutasFavoritos
  include Routing

  COMANDO_MARCAR_FAVORITO = %r{/marcarfavorito (?<id_contenido>\d+)}
  COMANDO_MIS_FAVORITOS = '/misfavoritos'.freeze

  RESPUESTA_MARCAR_FAVORITOS_EXITO = 'Contenido añadido a favoritos'.freeze
  RESPUESTA_MARCAR_FAVORITOS_ERROR = 'Error, no se puede marcar un favorito en este momento, intentelo mas tarde'.freeze

  RESPUESTA_LISTA_DE_FAVORITOS_VACIA = 'Parece que no tienes favoritos! Empieza a marcar tus contenidos como favoritos para verlos aquí.'.freeze

  on_message_pattern COMANDO_MARCAR_FAVORITO do |bot, message, args|
    id_contenido = args['id_contenido']
    id_telegram = message.from.id

    conector_api = ConectorApi.new

    plataforma = Plataforma.new(conector_api)

    begin
      plataforma.marcar_contenido_como_favorito(id_telegram, id_contenido)

      text = RESPUESTA_MARCAR_FAVORITOS_EXITO
    rescue StandardError => _e
      text = RESPUESTA_MARCAR_FAVORITOS_ERROR
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message COMANDO_MIS_FAVORITOS do |bot, message|
    id_telegram = message.from.id.to_i

    conector_api = ConectorApi.new

    plataforma = Plataforma.new(conector_api)

    begin
      favoritos = plataforma.obtener_favoritos(id_telegram)

      text = "Aquí tienes tu listado de favoritos:\n#{generar_lista_de_contenidos(favoritos)}"
    rescue StandardError => _e
      text = RESPUESTA_LISTA_DE_FAVORITOS_VACIA
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
