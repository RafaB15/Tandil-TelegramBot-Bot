require "#{File.dirname(__FILE__)}/utiles"

module RutasFavoritos
  include Routing

  COMANDO_MARCAR_FAVORITO = %r{/marcarfavorito (?<id_contenido>\d+)}
  COMANDO_MIS_FAVORITOS = '/misfavoritos'.freeze

  RESPUESTA_LISTA_DE_FAVORITOS_VACIA = 'Parece que no tienes favoritos! Empieza a marcar tus contenidos como favoritos para verlos aquí.'.freeze
  RESPUESTA_MARCAR_FAVORITOS_EXITO = 'Contenido añadido a favoritos'.freeze
  RESPUESTA_MARCAR_FAVORITOS_ERROR = 'Error al guardar favorito'.freeze

  on_message_pattern COMANDO_MARCAR_FAVORITO do |bot, message, args|
    id_contenido = args['id_contenido'].to_i
    id_telegram = message.from.id.to_i

    respuesta = ConectorApi.new.marcar_contenido_como_favorito(id_telegram, id_contenido)

    estado = respuesta.status

    text = if estado == 201
             RESPUESTA_MARCAR_FAVORITOS_EXITO
           else
             RESPUESTA_MARCAR_FAVORITOS_ERROR
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message COMANDO_MIS_FAVORITOS do |bot, message|
    id_telegram = message.from.id.to_i

    respuesta = ConectorApi.new.obtener_favoritos(id_telegram)

    favoritos = JSON.parse(respuesta.body)

    text = if favoritos.empty?
             RESPUESTA_LISTA_DE_FAVORITOS_VACIA
           else
             "Aquí tienes tu listado de favoritos:\n#{generar_lista_de_contenidos(favoritos)}"
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
