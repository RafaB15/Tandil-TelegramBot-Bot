require_relative 'utiles'

module RutasUsuarios
  include Routing

  COMANDO_REGISTRAR_USUARIO = %r{/registrar (?<email>.*)}

  MAPA_DE_ERRORES_REGISTRAR = {
    'ErrorIDTelegramYaAsociadoAUnaCuentaExistenteEnLaAPI' => 'Error, tu usuario de telegram ya esta asociado a una cuenta existente',
    'ErrorEmailYaAsociadoAUnaCuentaExistenteEnLaAPI' => 'Error, el email ingresado ya esta asociado a una cuenta existente',
    'ErrorAlInstanciarUsuarioEmailInvalido' => 'Error, tiene que enviar un email válido',
    'ErrorPredeterminado' => 'Error de la API'
  }.freeze

  on_message_pattern COMANDO_REGISTRAR_USUARIO do |bot, message, args, logger|
    email = args['email']
    id_telegram = message.from.id

    logger.debug "[BOT] /registrar #{email}"

    conector_api = ConectorApi.new(logger)

    plataforma = Plataforma.new(conector_api)

    begin
      plataforma.registrar_usuario(email, id_telegram)

      nombre_usuario = message.from.first_name

      text = "Bienvenido, cinéfilo #{nombre_usuario}!"
    rescue StandardError => e
      text = manejar_error(MAPA_DE_ERRORES_REGISTRAR, e)
    end

    logger.debug "[BOT] Respuesta: #{text}"

    bot.api.send_message(chat_id: message.chat.id, text:)
  end
end
