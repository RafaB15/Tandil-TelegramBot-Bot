require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/../lib/conector_api"

class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}")
  end

  on_message '/version' do |bot, message|
    version_api = ConectorApi.new.obtener_version

    bot.api.send_message(chat_id: message.chat.id, text: "version bot: #{Version.current}, version api: #{version_api}")
  end

  on_message_pattern %r{/registrar (?<email>.*)} do |bot, message, args|
    email_valido = args['email'].match?(/\A[\w+-.]+@[a-z\d-]+(.[a-z]+)*.[a-z]+\z/i)
    id_telegram = message.from.id.to_i
    text = 'Error, tiene que enviar un email válido'

    if email_valido
      conector_api = ConectorApi.new
      conector_api.crear_usuario(args['email'], id_telegram)

      text = if conector_api.estado == 201
               "Bienvenido, cinéfilo #{message.from.first_name}!"
             elsif conector_api.estado == 409
               if conector_api.respuesta['details']['field'] == 'id_telegram'
                 'Error, tu usuario de telegram ya esta asociado a una cuenta existente'
               else
                 'Error, el email ingresado ya esta asociado a una cuenta existente'
               end
             else
               'Error de la API'
             end
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message '/masvistos' do |bot, message|
    conector_api = ConectorApi.new
    conector_api.obtener_peliculas_mas_vistas
    top_peliculas = conector_api.respuesta

    if top_peliculas.empty?
      bot.api.send_message(chat_id: message.chat.id, text: 'No hay datos de visualizaciones de películas en el momento')
    else
      respuesta = "Las películas con más visualizaciones son:\n"
      top_peliculas.each do |pelicula|
        id_pelicula = pelicula['id']
        titulo = pelicula['pelicula']['titulo']
        anio = pelicula['pelicula']['anio']
        genero = pelicula['pelicula']['genero']
        respuesta += "  [ID: #{id_pelicula}] #{titulo} (#{genero}, #{anio})\n"
      end

      bot.api.send_message(chat_id: message.chat.id, text: respuesta)
    end
  end

  on_message_pattern %r{/calificar (?<id_pelicula>\d+) (?<calificacion>\d+)} do |bot, message, args|
    id_pelicula = args['id_pelicula'].to_i
    calificacion = args['calificacion'].to_i
    id_telegram = message.from.id.to_i

    conector_api = ConectorApi.new
    conector_api.calificar_contenido(id_telegram, id_pelicula, calificacion)

    text = if conector_api.estado == 201
             'Calificacion registrada exitosamente'
           else
             'Error al calificar la película. Inténtalo de nuevo más tarde.'
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern %r{/marcar_favorita (?<id_pelicula>\d+)} do |bot, message, args|
    id_pelicula = args['id_pelicula'].to_i
    conector_api = ConectorApi.new
    conector_api.marcar_favorita(message.from.id.to_i, id_pelicula)

    text = if conector_api.estado == 201
             'Contenido añadido a favoritos'
           else
             'Error al guardar favorito'
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern %r{/buscartitulo (?<titulo>.+)} do |bot, message, args|
    conector_api = ConectorApi.new
    conector_api.buscar_pelicula_por_titulo(args['titulo'])
    peliculas = conector_api.respuesta

    respuesta = if peliculas.empty?
                  'No se encontraron resultados para la búsqueda'
                else
                  "Acá están los titulos que coinciden con tu busqueda:\n#{generar_lista_de_contenidos(peliculas)}"
                end
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/misfavoritos' do |bot, message|
    conector_api = ConectorApi.new
    conector_api.obtener_favoritos(message.from.id.to_i)
    favoritos = conector_api.respuesta

    respuesta = if favoritos.empty?
                  'Parece que no tienes favoritos! Empieza a marcar tus contenidos como favoritos para verlos aquí.'
                else
                  "Aquí tienes tu listado de favoritos:\n#{generar_lista_de_contenidos(favoritos)}"
                end
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/sugerencias' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'No contamos con sugerencias adecuadas en este momento')
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '¿Uh? ¡No te entiendo! ¿Me repetís la pregunta?')
  end
end

def generar_lista_de_contenidos(contenidos)
  respuesta = ''
  contenidos.each do |contenido|
    id_contenido = contenido['id']
    titulo = contenido['titulo']
    anio = contenido['anio']
    genero = contenido['genero']
    respuesta += "- [ID: #{id_contenido}] #{titulo} (#{genero}, #{anio})\n"
  end
  respuesta
end
