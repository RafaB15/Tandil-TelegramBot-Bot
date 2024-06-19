require_relative 'utiles'

module RutasContenidos
  include Routing

  COMANDO_BUSCAR_TITULO = %r{/buscartitulo (?<titulo>.+)}
  COMANDO_MAS_INFO = %r{/masinfo (?<id_contenido>-?\d+)}

  MAPA_DE_ERRORES_BUSCAR_TITULO = {
    'ErrorListaVacia' => 'No se encontraron resultados para la búsqueda',
    'ErrorPredeterminado' => 'Error, no se pueden ver titulos de contenidos en este momento, intentelo mas tarde'
  }.freeze

  MAPA_DE_ERRORES_MAS_INFO = {
    'ErrorAlDetallarContenidoNoExisteContenidoEnLaAPI' => 'No se encontraron resultados para el contenido buscado',
    'ErrorAlDetallarContenidoNoExisteContenidoEnOMDb' => 'No se encontraron detalles para el contenido buscado',
    'ErrorPredeterminado' => 'Error, no se puede pedir mas informacion acerca de un contenido en este momento, intentelo mas tarde'
  }.freeze

  on_message_pattern COMANDO_BUSCAR_TITULO do |bot, message, args, logger|
    titulo = args['titulo']

    logger.debug "[BOT] /buscartitulo titulo: #{titulo}"

    conector_api = ConectorApi.new(logger)

    plataforma = Plataforma.new(conector_api)

    begin
      contenidos = plataforma.buscar_contenido_por_titulo(titulo)

      text = "Acá están los titulos que coinciden con tu busqueda:\n#{generar_lista_de_contenidos(contenidos)}"
    rescue StandardError => e
      text = manejar_error(MAPA_DE_ERRORES_BUSCAR_TITULO, e)
    end

    logger.debug "[BOT] Respuesta: #{text}"

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern COMANDO_MAS_INFO do |bot, message, args, logger|
    id_contenido = args['id_contenido']
    id_telegram = message.from.id

    logger.debug "[BOT] /masinfo id_contenido: #{id_contenido}"
    conector_api = ConectorApi.new(logger)

    plataforma = Plataforma.new(conector_api)

    begin
      detalles_contenido = plataforma.obtener_detalles_de_contenido(id_contenido, id_telegram)

      text = "Info de #{detalles_contenido['titulo']} (#{id_contenido}):\n#{generar_lista_de_detalles(detalles_contenido)}"
    rescue StandardError => e
      text = manejar_error(MAPA_DE_ERRORES_MAS_INFO, e)
    end

    logger.debug "[BOT] Respuesta: #{text}"

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end

def obtener_mas_informacion(detalles_contenido, campo)
  detalles_contenido[campo].nil? ? 'No disponible' : detalles_contenido[campo]
end

def generar_lista_de_detalles(detalles_contenido)
  respuesta = ''

  if detalles_contenido.key?('fue_visto')
    visto_text = detalles_contenido['fue_visto'] ? '¡Ya lo viste!' : '¡No lo viste!'
    respuesta += "- #{visto_text}\n"
  end

  respuesta += "- Anio: #{obtener_mas_informacion(detalles_contenido, 'anio')}\n"
  respuesta += "- Premios: #{obtener_mas_informacion(detalles_contenido, 'premios')}\n"
  respuesta += "- Director: #{obtener_mas_informacion(detalles_contenido, 'director')}\n"
  respuesta += "- Sinopsis: #{obtener_mas_informacion(detalles_contenido, 'sinopsis')}\n"

  respuesta
end
