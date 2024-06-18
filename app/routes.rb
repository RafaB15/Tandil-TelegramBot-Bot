require_relative 'rutas/utiles'
require_relative '../lib/version'
Dir[File.join(__dir__, 'rutas', '*.rb')].each { |file| require file }

class Routes
  include Routing
  include RutasSugerencias
  include RutasFavoritos
  include RutasCalificaciones
  include RutasUsuarios
  include RutasContenidos

  RESPUESTA_AYUDA_LISTA_DE_COMANDOS = [
    'Sé responder los siguientes mensajes:',
    '- /version: Devuelve la versión en la que el Bot está corriendo',
    '- /registrar <email>: Registra tu usuario de telegram asignandole un email',
    '- /sugerenciasmasvistos: Devuelve una lista con los 3 contenidos mas vistos de toda la plataforma',
    '- /calificar <id_contenido> <calificacion>: Si estas registrado podes calificar con una calificacion del 1 al 5 cualquier contenido',
    '- /marcarfavorito <id_contenido>: Si estas registrado podes marcar un contenido como favorito',
    '- /buscartitulo <titulo>: Devuelve todos los contenidos en nuestra bases de datos que sean similares a tu busqueda',
    '- /misfavoritos: Si estas registrado, devuelve tu lista de favoritos',
    '- /sugerenciasnuevos: Devuelve una lista con los 5 contenidos mas nuevos de la ultima semana',
    '- /masinfo <id_contenido>: Devuelve informacion extra acerca de la pelicula - director, premios, sinopsis'
  ].join("\n")

  RESPUESTA_DEFAULT = '¿Uh? ¡No te entiendo! ¿Me repetís la pregunta?'.freeze

  COMANDO_START = '/start'.freeze
  COMANDO_VERSION = '/version'.freeze
  COMANDO_AYUDA = %r{/ayuda}

  on_message COMANDO_START do |bot, message|
    text = "Hola, #{message.from.first_name}"

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message COMANDO_VERSION do |bot, message|
    respuesta = ConectorApi.new.obtener_version

    version_api = JSON.parse(respuesta.body)['version']

    text = "version bot: #{Version.current}, version api: #{version_api}"

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  on_message_pattern COMANDO_AYUDA do |bot, message|
    text = RESPUESTA_AYUDA_LISTA_DE_COMANDOS

    bot.api.send_message(chat_id: message.chat.id, text:)
  end

  default do |bot, message|
    text = RESPUESTA_DEFAULT

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
