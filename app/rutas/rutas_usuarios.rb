require "#{File.dirname(__FILE__)}/utiles"

module RutasUsuarios
  include Routing

  COMANDO_REGISTRAR_USUARIO = %r{/registrar (?<email>.*)}

  REGEX_EMAIL_VALIDO = /\A[\w+-.]+@[a-z\d-]+(.[a-z]+)*.[a-z]+\z/i
  RESPUESTA_EMAIL_INVALIDO = 'Error, tiene que enviar un email válido'.freeze

  on_message_pattern COMANDO_REGISTRAR_USUARIO do |bot, message, args|
    email_valido = args['email'].match?(REGEX_EMAIL_VALIDO)

    email = args['email']
    id_telegram = message.from.id.to_i

    text = RESPUESTA_EMAIL_INVALIDO

    if email_valido
      respuesta = ConectorApi.new.crear_usuario(email, id_telegram)

      estado = respuesta.status
      cuerpo = JSON.parse(respuesta.body)

      nombre_usuario = message.from.first_name

      text = ensamblar_respuesta_registro(estado, cuerpo, nombre_usuario)
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end

def ensamblar_respuesta_registro(estado, cuerpo, nombre_usuario)
  if estado == 201
    "Bienvenido, cinéfilo #{nombre_usuario}!"
  elsif estado == 409
    if cuerpo['details']['field'] == 'id_telegram'
      'Error, tu usuario de telegram ya esta asociado a una cuenta existente'
    else
      'Error, el email ingresado ya esta asociado a una cuenta existente'
    end
  else
    'Error de la API'
  end
end
