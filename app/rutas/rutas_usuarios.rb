require_relative 'utiles'

module RutasUsuarios
  include Routing

  COMANDO_REGISTRAR_USUARIO = %r{/registrar (?<email>.*)}

  ERROR_MAP = {
    'ErrorIDTelegramYaAsociadoAUnaCuentaExistenteEnLaAPI' => 'Error, tu usuario de telegram ya esta asociado a una cuenta existente',
    'ErrorEmailYaAsociadoAUnaCuentaExistenteEnLaAPI' => 'Error, el email ingresado ya esta asociado a una cuenta existente',
    'ErrorAlInstanciarUsuarioEmailInvalido' => 'Error, tiene que enviar un email válido'
  }.freeze

  ERROR_DEFAULT = 'Error de la API'.freeze

  on_message_pattern COMANDO_REGISTRAR_USUARIO do |bot, message, args|
    email = args['email']
    id_telegram = message.from.id

    conector_api = ConectorApi.new

    plataforma = Plataforma.new(conector_api)

    begin
      plataforma.registrar_usuario(email, id_telegram)

      nombre_usuario = message.from.first_name

      text = "Bienvenido, cinéfilo #{nombre_usuario}!"
    rescue StandardError => e
      text = if ERROR_MAP.key?(e.class.name)
               ERROR_MAP[e.class.name]
             else
               ERROR_DEFAULT
             end
    end

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
