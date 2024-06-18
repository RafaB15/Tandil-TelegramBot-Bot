require 'spec_helper'
require 'web_mock'

require_relative '../../lib/conector_api'

describe ConectorApi do
  describe 'registrar_usuario' do
    it 'should get a /registrar message with new user and respond with welcome message' do
      email = 'juan@gmail.com'
      id_telegram = 123_456_789
      estado = 201

      usuario = instance_double(Usuario, email:, id_telegram:)
      stub_post_request_usuario(email, id_telegram, estado)

      described_class.new.registrar_usuario(usuario)
    end

    it 'should get a /registrar message with invalid email and respond with invalid email message' do
      email = 'juan'
      id_telegram = 123_456_789
      estado = 422

      usuario = instance_double(Usuario, email:, id_telegram:)
      stub_post_request_usuario(email, id_telegram, estado)

      expect { described_class.new.registrar_usuario(usuario) }.to raise_error(IOError)
    end

    it 'deberia recibir un mensaje /registrar con número de telegram repetido y responder con un mensaje de error' do
      id_telegram = 123_456_789

      usuario = instance_double(Usuario, email: 'juan@gmail.com', id_telegram:)
      stub_post_request_usuario('juan@gmail.com', id_telegram, 201)
      described_class.new.registrar_usuario(usuario)

      message = 'El telegram ID ya está asociado con una cuenta existente.'
      field = :id_telegram
      usuario = instance_double(Usuario, email: 'pablito@gmail.com', id_telegram:)
      stub_post_request_usuario_error('pablito@gmail.com', id_telegram, 409, message, field)

      expect { described_class.new.registrar_usuario(usuario) }.to raise_error(ErrorIDTelegramYaAsociadoAUnaCuentaExistenteEnLaAPI)
    end

    it 'deberia recibir un mensaje /registrar con un email ya registrado y responder con un error' do
      email = 'juan@gmail.com'

      usuario = instance_double(Usuario, email:, id_telegram: 123_456_789)
      stub_post_request_usuario(email, 123_456_789, 201)
      described_class.new.registrar_usuario(usuario)

      message = 'El email ya está asociado con una cuenta existente.'
      field = :email
      usuario = instance_double(Usuario, email:, id_telegram: 987_654_321)
      stub_post_request_usuario_error(email, 987_654_321, 409, message, field)

      expect { described_class.new.registrar_usuario(usuario) }.to raise_error(ErrorEmailYaAsociadoAUnaCuentaExistenteEnLaAPI)
    end
  end
end
