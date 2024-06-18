require_relative 'utiles'

module RutasContenidos
  include Routing

  COMANDO_BUSCAR_TITULO = %r{/buscartitulo (?<titulo>.+)}
  COMANDO_MAS_INFO = %r{/masinfo (?<id_contenido>-?\d+)}

  RESPUESTA_LISTA_DE_CONTENIDOS_VACIA = 'No se encontraron resultados para la búsqueda'.freeze

  on_message_pattern COMANDO_BUSCAR_TITULO do |bot, message, args|
    titulo = args['titulo']

    respuesta = ConectorApi.new.buscar_contenido_por_titulo(titulo)

    contenidos = JSON.parse(respuesta.body)

    text = if contenidos.empty?
             RESPUESTA_LISTA_DE_CONTENIDOS_VACIA
           else
             "Acá están los titulos que coinciden con tu busqueda:\n#{generar_lista_de_contenidos(contenidos)}"
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern COMANDO_MAS_INFO do |bot, message, args|
    id_contenido = args['id_contenido']
    id_telegram = message.from.id.to_i

    respuesta = ConectorApi.new.obtener_detalles_de_contenido(id_contenido, id_telegram)

    estado = respuesta.status
    detalles_contenido = JSON.parse(respuesta.body)

    text = ensamblar_respuesta_mas_info(estado, detalles_contenido, id_contenido)

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

def ensamblar_respuesta_mas_info(estado, detalles_contenido, id_contenido)
  respuesta = 'Error de la API'

  if estado == 200
    respuesta = "Info de #{detalles_contenido['titulo']} (#{id_contenido}):\n#{generar_lista_de_detalles(detalles_contenido)}"
  elsif estado == 404
    if detalles_contenido['details']['field'] == 'contenido'
      respuesta = 'No se encontraron resultados para el contenido buscado'
    elsif detalles_contenido['details']['field'] == 'omdb'
      respuesta = 'No se encontraron detalles para el contenido buscado'
    end
  end

  respuesta
end
