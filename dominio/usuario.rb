class Usuario
  attr_reader :email, :id_telegram

  REGEX_EMAIL_VALIDO = /\A[\w+-.]+@[a-z\d-]+(.[a-z]+)*.[a-z]+\z/i

  def initialize(email, id_telegram)
    raise ErrorAlInstanciarUsuarioEmailInvalido unless es_el_email_valido?(email)

    @email = email
    @id_telegram = id_telegram.to_i
  end

  private

  def es_el_email_valido?(email)
    email.match?(REGEX_EMAIL_VALIDO)
  end
end

class ErrorAlInstanciarUsuarioEmailInvalido < ArgumentError
  MSG_DE_ERROR = 'Error: email invalido'.freeze

  def initialize(msg_de_error = MSG_DE_ERROR)
    super(msg_de_error)
  end
end
