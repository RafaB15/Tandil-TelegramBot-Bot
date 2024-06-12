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

      text = ensamblar_respuesta_registro(conector_api, message)
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
      respuesta = ensamblar_respuesta(top_peliculas)

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

    respuesta = choose_output(peliculas, 'No se encontraron resultados para la búsqueda',
                              "Acá están los titulos que coinciden con tu busqueda:\n#{generar_lista_de_contenidos(peliculas)}")
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/misfavoritos' do |bot, message|
    conector_api = ConectorApi.new
    conector_api.obtener_favoritos(message.from.id.to_i)
    favoritos = conector_api.respuesta

    respuesta = choose_output(favoritos, 'Parece que no tienes favoritos! Empieza a marcar tus contenidos como favoritos para verlos aquí.',
                              "Aquí tienes tu listado de favoritos:\n#{generar_lista_de_contenidos(favoritos)}")
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/sugerenciasnuevos' do |bot, message|
    conector_api = ConectorApi.new
    conector_api.obtener_sugerencias
    sugerencias = conector_api.respuesta

    respuesta = choose_output(sugerencias, '¡No hay nuevos contenidos esta semana, estate atento a las novedades!',
                              "Acá tienes algunas sugerencias:\n#{generar_lista_de_contenidos(sugerencias)}")
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '¿Uh? ¡No te entiendo! ¿Me repetís la pregunta?')
  end

  on_message_pattern %r{/masinfo (?<id_pelicula>.+)} do |bot, message, args|
    id_pelicula = args['id_pelicula']
    conector_api = ConectorApi.new
    conector_api.obtener_detalles_de_pelicula(id_pelicula)
    detalles_pelicula = conector_api.respuesta

    respuesta = ensamblar_respuesta_mas_info(conector_api.estado, detalles_pelicula)
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
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

def choose_output(options, empty_response, list_response)
  if options.empty?
    empty_response
  else
    list_response
  end
end

def obtener_mas_informacion(detalles, campo)
  detalles[campo].to_s.strip.empty? ? 'No disponible' : detalles[campo]
end

def generar_lista_de_detalles(detalles_pelicula)
  respuesta = "- Anio: #{obtener_mas_informacion(detalles_pelicula, 'anio')}\n"
  respuesta += "- Premios: #{obtener_mas_informacion(detalles_pelicula, 'premios')}\n"
  respuesta += "- Director: #{obtener_mas_informacion(detalles_pelicula, 'director')}\n"
  respuesta += "- Sinopsis: #{obtener_mas_informacion(detalles_pelicula, 'sinopsis')}\n"

  respuesta
end

def ensamblar_respuesta(top_peliculas)
  respuesta = "Las películas con más visualizaciones son:\n"
  top_peliculas.each do |pelicula|
    id_pelicula = pelicula['id']
    titulo = pelicula['pelicula']['titulo']
    anio = pelicula['pelicula']['anio']
    genero = pelicula['pelicula']['genero']
    respuesta += "  [ID: #{id_pelicula}] #{titulo} (#{genero}, #{anio})\n"
  end
  respuesta
end

def ensamblar_respuesta_registro(conector_api, message)
  if conector_api.estado == 201
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

def ensamblar_respuesta_mas_info(estado, detalles_pelicula)
  if estado == 200
    "Detalles para la película #{detalles_pelicula['titulo']}:\n#{generar_lista_de_detalles(detalles_pelicula)}"
  elsif estado == 404
    if detalles_pelicula['error'] == 'no encontrado'
      'No se encontraron resultados para el contenido buscado'
    elsif detalles_pelicula['error'] == 'no hay detalles para mostrar'
      'No se encontraron detalles para el contenido buscado'
    else
      'Error de la API'
    end
  else
    'Error de la API'
  end
end
