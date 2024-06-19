require_relative 'utiles'

module RutasSugerencias
  include Routing

  COMANDO_SUGERENCIAS_MAS_VISTOS = '/sugerenciasmasvistos'.freeze
  COMANDO_SUGERENCIAS_NUEVOS = '/sugerenciasnuevos'.freeze

  RESPUESTA_LISTA_DE_SUGERENCIAS_MAS_VISTOS_VACIA = 'No hay datos de visualizaciones de contenidos en este momento'.freeze
  RESPUESTA_LISTA_DE_SUGERENCIAS_NUEVOS_VACIA = '¡No hay nuevos contenidos esta semana, estate atento a las novedades!'.freeze

  on_message COMANDO_SUGERENCIAS_MAS_VISTOS do |bot, message|
    conector_api = ConectorApi.new

    plataforma = Plataforma.new(conector_api)

    begin
      sugerencias_mas_vistos = plataforma.obtener_mas_vistos

      text = ensamblar_respuesta_sugerencias_mas_vistos(sugerencias_mas_vistos)

      bot.api.send_message(chat_id: message.chat.id, text:)
    rescue StandardError => _e
      text = RESPUESTA_LISTA_DE_SUGERENCIAS_MAS_VISTOS_VACIA
    end
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
    titulo = contenido['contenido']['titulo']
    anio = contenido['contenido']['anio']
    genero = contenido['contenido']['genero']

    respuesta += "  [ID: #{id_contenido}] #{titulo} (#{genero}, #{anio})\n"
  end

  respuesta
end
