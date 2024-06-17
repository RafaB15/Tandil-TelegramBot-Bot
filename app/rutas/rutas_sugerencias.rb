require "#{File.dirname(__FILE__)}/utiles"

module RutasSugerencias
  include Routing

  COMANDO_SUGERENCIAS_MAS_VISTOS = '/sugerenciasmasvistos'.freeze
  COMANDO_SUGERENCIAS_NUEVOS = '/sugerenciasnuevos'.freeze

  RESPUESTA_LISTA_DE_SUGERENCIAS_MAS_VISTOS_VACIA = 'No hay datos de visualizaciones de películas en el momento'.freeze
  RESPUESTA_LISTA_DE_SUGERENCIAS_NUEVOS_VACIA = '¡No hay nuevos contenidos esta semana, estate atento a las novedades!'.freeze

  on_message COMANDO_SUGERENCIAS_MAS_VISTOS do |bot, message|
    respuesta = ConectorApi.new.obtener_sugerencias_contenidos_mas_vistos

    sugerencias_mas_vistos = JSON.parse(respuesta.body)

    text = if sugerencias_mas_vistos.empty?
             RESPUESTA_LISTA_DE_SUGERENCIAS_MAS_VISTOS_VACIA
           else
             ensamblar_respuesta_sugerencias_mas_vistos(sugerencias_mas_vistos)
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message COMANDO_SUGERENCIAS_NUEVOS do |bot, message|
    respuesta = ConectorApi.new.obtener_sugerencias_contenidos_mas_nuevos

    sugerencias_nuevos = JSON.parse(respuesta.body)

    text = if sugerencias_nuevos.empty?
             RESPUESTA_LISTA_DE_SUGERENCIAS_NUEVOS_VACIA
           else
             "Acá tienes algunas sugerencias:\n#{generar_lista_de_contenidos(sugerencias_nuevos)}"
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end

def ensamblar_respuesta_sugerencias_mas_vistos(sugerencias_mas_vistos)
  respuesta = "Las películas con más visualizaciones son:\n"

  sugerencias_mas_vistos.each do |contenido|
    id_contenido = contenido['id']
    titulo = contenido['pelicula']['titulo']
    anio = contenido['pelicula']['anio']
    genero = contenido['pelicula']['genero']

    respuesta += "  [ID: #{id_contenido}] #{titulo} (#{genero}, #{anio})\n"
  end

  respuesta
end
