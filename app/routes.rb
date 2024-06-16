require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/../lib/conector_api"

LISTA_DE_COMANDOS = "Sé responder los siguientes mensajes:
- /version: Devuelve la versión en la que el Bot está corriendo
- /registrar <email>: Registra tu usuario de telegram asignandole un email
- /sugerenciasmasvistos: Devuelve una lista con los 3 contenidos mas vistos de toda la plataforma
- /calificar <id_contenido> <calificacion>: Si estas registrado podes calificar con una calificacion del 1 al 5 cualquier contenido
- /marcarfavorito <id_contenido>: Si estas registrado podes marcar un contenido como favorito
- /buscartitulo <titulo>: Devuelve todos los contenidos en nuestra bases de datos que sean similares a tu busqueda
- /misfavoritos: Si estas registrado, devuelve tu lista de favoritos
- /sugerenciasnuevos: Devuelve una lista con los 5 contenidos mas nuevos de la ultima semana
- /masinfo <id_pelicula>: Devuelve informacion extra acerca de la pelicula - director, premios, sinopsis".freeze

class Routes
  include Routing

  on_message '/start' do |bot, message|
    text = "Hola, #{message.from.first_name}"
    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message '/version' do |bot, message|
    version_api = ConectorApi.new.obtener_version

    text = "version bot: #{Version.current}, version api: #{version_api}"
    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern %r{/registrar (?<email>.*)} do |bot, message, args|
    email_valido = args['email'].match?(/\A[\w+-.]+@[a-z\d-]+(.[a-z]+)*.[a-z]+\z/i)

    email = args['email']
    id_telegram = message.from.id.to_i

    text = 'Error, tiene que enviar un email válido'

    if email_valido
      conector_api = ConectorApi.new
      conector_api.crear_usuario(email, id_telegram)

      nombre_usuario = message.from.first_name

      text = ensamblar_respuesta_registro(conector_api, nombre_usuario)
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message '/sugerenciasmasvistos' do |bot, message|
    conector_api = ConectorApi.new
    conector_api.obtener_sugerencias_contenidos_mas_vistos
    top_contenido = conector_api.cuerpo

    if top_contenido.empty?
      bot.api.send_message(chat_id: message.chat.id, text: 'No hay datos de visualizaciones de películas en el momento')
    else
      respuesta = ensamblar_respuesta(top_contenido)

      bot.api.send_message(chat_id: message.chat.id, text: respuesta)
    end
  end

  on_message_pattern %r{/calificar (?<id_contenido>\d+) (?<puntaje>\d+)} do |bot, message, args|
    id_contenido = args['id_contenido'].to_i
    puntaje = args['puntaje'].to_i
    id_telegram = message.from.id.to_i

    conector_api = ConectorApi.new
    conector_api.calificar_contenido(id_telegram, id_contenido, puntaje)

    if conector_api.estado == 201
      text = 'Calificacion registrada exitosamente'
    elsif conector_api.estado == 422
      text = '¡Aún no viste este contenido, miralo para poder calificarlo!'
    else
      'Error al calificar la película. Inténtalo de nuevo más tarde.'
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern %r{/marcarfavorito (?<id_contenido>\d+)} do |bot, message, args|
    id_contenido = args['id_contenido'].to_i
    id_telegram = message.from.id.to_i

    conector_api = ConectorApi.new
    conector_api.marcar_contenido_como_favorito(id_telegram, id_contenido)

    text = if conector_api.estado == 201
             'Contenido añadido a favoritos'
           else
             'Error al guardar favorito'
           end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern %r{/buscartitulo (?<titulo>.+)} do |bot, message, args|
    titulo = args['titulo']

    conector_api = ConectorApi.new
    conector_api.buscar_contenido_por_titulo(titulo)
    contenidos = conector_api.cuerpo

    respuesta = ensamblar_respuesta_lista(contenidos, 'No se encontraron resultados para la búsqueda',
                                          "Acá están los titulos que coinciden con tu busqueda:\n#{generar_lista_de_contenidos(contenidos)}")
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/misfavoritos' do |bot, message|
    id_telegram = message.from.id.to_i

    conector_api = ConectorApi.new
    conector_api.obtener_favoritos(id_telegram)
    favoritos = conector_api.cuerpo

    respuesta = ensamblar_respuesta_lista(favoritos, 'Parece que no tienes favoritos! Empieza a marcar tus contenidos como favoritos para verlos aquí.',
                                          "Aquí tienes tu listado de favoritos:\n#{generar_lista_de_contenidos(favoritos)}")
    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  on_message '/sugerenciasnuevos' do |bot, message|
    conector_api = ConectorApi.new
    conector_api.obtener_sugerencias_contenidos_mas_nuevos

    sugerencias = conector_api.cuerpo

    text = ensamblar_respuesta_lista(sugerencias, '¡No hay nuevos contenidos esta semana, estate atento a las novedades!',
                                     "Acá tienes algunas sugerencias:\n#{generar_lista_de_contenidos(sugerencias)}")

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern %r{/masinfo (?<id_contenido>.+)} do |bot, message, args|
    id_contenido = args['id_contenido']
    id_telegram = message.from.id.to_i

    conector_api = ConectorApi.new
    conector_api.obtener_detalles_de_contenido(id_contenido, id_telegram)

    detalles_contenido = conector_api.cuerpo

    text = ensamblar_respuesta_mas_info(conector_api.estado, detalles_contenido, id_contenido)

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern %r{/ayuda} do |bot, message|
    text = LISTA_DE_COMANDOS

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  default do |bot, message|
    text = '¿Uh? ¡No te entiendo! ¿Me repetís la pregunta?'

    bot.api.send_message(chat_id: message.chat.id, text:)
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

def ensamblar_respuesta_lista(sugerencias, respuesta_lista_vacia, respuesta_lista_con_contenido)
  if sugerencias.empty?
    respuesta_lista_vacia
  else
    respuesta_lista_con_contenido
  end
end

def obtener_mas_informacion(detalles, campo)
  detalles[campo].nil? ? 'No disponible' : detalles[campo]
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

def ensamblar_respuesta(top_contenido)
  respuesta = "Las películas con más visualizaciones son:\n"
  top_contenido.each do |contenido|
    id_contenido = contenido['id']
    titulo = contenido['pelicula']['titulo']
    anio = contenido['pelicula']['anio']
    genero = contenido['pelicula']['genero']
    respuesta += "  [ID: #{id_contenido}] #{titulo} (#{genero}, #{anio})\n"
  end
  respuesta
end

def ensamblar_respuesta_registro(conector_api, nombre_usuario)
  if conector_api.estado == 201
    "Bienvenido, cinéfilo #{nombre_usuario}!"
  elsif conector_api.estado == 409
    if conector_api.cuerpo['details']['field'] == 'id_telegram'
      'Error, tu usuario de telegram ya esta asociado a una cuenta existente'
    else
      'Error, el email ingresado ya esta asociado a una cuenta existente'
    end
  else
    'Error de la API'
  end
end

def ensamblar_respuesta_mas_info(estado, detalles_contenido, id_contenido)
  if estado == 200
    "Info de #{detalles_contenido['titulo']} (#{id_contenido}):\n#{generar_lista_de_detalles(detalles_contenido)}"
  elsif estado == 404
    if detalles_contenido['error'] == 'no encontrado'
      'No se encontraron resultados para el contenido buscado'
    elsif detalles_contenido['error'] == 'no hay detalles para mostrar'
      'No se encontraron detalles para el contenido buscado'
    else
      'Error de la API'
    end
  else
    'Error de la API'
  end
end
