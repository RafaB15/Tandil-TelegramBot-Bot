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
    telegram_id = message.from.id.to_i
    text = 'Error, tiene que enviar un email válido'

    if email_valido
      conector_api = ConectorApi.new
      conector_api.crear_usuario(args['email'], telegram_id)

      text = if conector_api.estado == 201
               "Bienvenido, cinéfilo #{message.from.first_name}!"
             elsif conector_api.estado == 409
               if conector_api.respuesta['field'] == 'telegram_id'
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
    top_peliculas = ConectorApi.new.obtener_peliculas_mas_vistas
    respuesta = "Las películas con más visualizaciones son:\n"
    top_peliculas.each_with_index do |pelicula, index|
      respuesta += "  #{index + 1}. #{pelicula['titulo']} (#{pelicula['id']})\n"
    end

    bot.api.send_message(chat_id: message.chat.id, text: respuesta)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '¿Uh? ¡No te entiendo! ¿Me repetís la pregunta?')
  end
end
