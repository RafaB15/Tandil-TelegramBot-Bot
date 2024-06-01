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

    if email_valido
      response_status = ConectorApi.new.crear_usuario(args['email'], telegram_id)
      if response_status == 201
        bot.api.send_message(chat_id: message.chat.id, text: "Bienvenido, cinéfilo #{message.from.first_name}!")
      elsif response_status == 409
        bot.api.send_message(chat_id: message.chat.id, text: 'Error, la cuenta de telegram sólo puede estar asociada a un mail')
      else
        bot.api.send_message(chat_id: message.chat.id, text: 'Error de la API')
      end
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'Error, tiene que enviar un email válido')
    end
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: '¿Uh? ¡No te entiendo! ¿Me repetís la pregunta?')
  end
end
