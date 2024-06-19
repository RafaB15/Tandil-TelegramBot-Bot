require_relative 'utiles'

module RutasFavoritos
  include Routing

  COMANDO_MARCAR_FAVORITO = %r{/marcarfavorito (?<id_contenido>\d+)}
  COMANDO_MIS_FAVORITOS = '/misfavoritos'.freeze

  MAPA_DE_RESPUESTAS_MARCAR_FAVORITOS = {
    'EXITO' => 'Contenido añadido a favoritos',
    'ERROR' => 'Error, no se puede marcar un favorito en este momento, intentelo mas tarde'
  }.freeze

  MAPA_DE_ERRORES_MIS_FAVORITOS = {
    'ErrorListaVacia' => 'Parece que no tienes favoritos! Empieza a marcar tus contenidos como favoritos para verlos aquí.',
    'ErrorPredeterminado' => 'Error, no se pueden ver tus favoritos en este momento, intentelo mas tarde'
  }.freeze

  on_message_pattern COMANDO_MARCAR_FAVORITO do |bot, message, args|
    id_contenido = args['id_contenido']
    id_telegram = message.from.id

    conector_api = ConectorApi.new

    plataforma = Plataforma.new(conector_api)

    begin
      plataforma.marcar_contenido_como_favorito(id_telegram, id_contenido)

      text = MAPA_DE_RESPUESTAS_MARCAR_FAVORITOS['EXITO']
    rescue StandardError => _e
      text = MAPA_DE_RESPUESTAS_MARCAR_FAVORITOS['ERROR']
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
    rescue StandardError => e
      text = manejar_error(MAPA_DE_ERRORES_MIS_FAVORITOS, e)
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
