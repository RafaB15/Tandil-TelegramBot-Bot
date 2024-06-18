require 'spec_helper'
require 'web_mock'

require_relative '../../lib/conector_api'

def stub_post_request_calificacion_puntaje_invalido(id_telegram, id_contenido, puntaje)
  response = { error: '', message: '', details: { field: 'calificacion' } }

  stub_request(:post, 'http://fake/calificaciones')
    .with(
      body: "{\"id_telegram\":#{id_telegram},\"id_contenido\":#{id_contenido},\"puntaje\":#{puntaje}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 422, body: response.to_json, headers: {})
end

describe ConectorApi do
  describe 'registrar_usuario' do
    it 'Deberia enviar los datos de un usuario para registrarlos en la API y devolver exito' do
      email = 'juan@gmail.com'
      id_telegram = 123_456_789
      estado = 201

      usuario = instance_double(Usuario, email:, id_telegram:)
      stub_post_request_usuario(email, id_telegram, estado)

      described_class.new.registrar_usuario(usuario)
    end

    it 'Deberia enviar los datos de un usuario con email invalido y levantar un error de I/O' do
      email = 'juan'
      id_telegram = 123_456_789
      estado = 422

      usuario = instance_double(Usuario, email:, id_telegram:)
      stub_post_request_usuario(email, id_telegram, estado)

      expect { described_class.new.registrar_usuario(usuario) }.to raise_error(IOError)
    end

    it 'Deberia enviar los datos de un usuario con un ID de Telegram ya en uso y levantar un error de ID Telegram ya asociado a una cuenta' do
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

    it 'Deberia enviar los datos de un usuario con un email ya en uso y levantar un error de email ya asociado a una cuenta' do
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

  describe 'calificar_contenido' do
    it 'Deberia enviar los datos de una calificacion para registrarlos en la API y devolver exito' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4
      estado = 201

      calificacion = instance_double(Calificacion, id_telegram:, id_contenido:, puntaje:)
      stub_post_request_calificaciones(id_telegram, id_contenido, puntaje, estado)

      described_class.new.calificar_contenido(calificacion)
    end

    it 'Deberia enviar los datos de una calificacion no vista aun por el usuario de telegram y levantar un error de usuario no vio el contenido' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4

      calificacion = instance_double(Calificacion, id_telegram:, id_contenido:, puntaje:)
      stub_post_request_calificacion_contenido_no_visto(id_telegram, id_contenido, puntaje)

      expect { described_class.new.calificar_contenido(calificacion) }.to raise_error(ErrorAlPedirCalificacionContenidoNoVistoPorUsuarioDeTelegram)
    end

    it 'Deberia enviar los datos de una calificacion con un puntaje negativo y levantar un error de puntaje invalido' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = -1

      calificacion = instance_double(Calificacion, id_telegram:, id_contenido:, puntaje:)
      stub_post_request_calificacion_puntaje_invalido(id_telegram, id_contenido, puntaje)

      expect { described_class.new.calificar_contenido(calificacion) }.to raise_error(ErrorAlInstanciarCalificacionPuntajeInvalido)
    end

    it 'Deberia enviar nuevos datos para registrar una calificacion ya calificada y devolver una calificacion con el puntaje anterior' do
      id_telegram = 123_456_789
      id_contenido = 50
      puntaje = 4
      puntaje_anterior = 5

      calificacion = Calificacion.new(id_telegram, id_contenido, puntaje)
      stub_post_request_recalificacion(id_telegram, id_contenido, puntaje, puntaje_anterior)

      calificacion_anterior = described_class.new.calificar_contenido(calificacion)

      expect(calificacion_anterior.puntaje).to eq puntaje_anterior
    end

    it 'Deberia enviar los datos de una calificacion con un contenido que no esta en la base de datos de la API y levantar un error de conido inexistente' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4

      calificacion = instance_double(Calificacion, id_telegram:, id_contenido:, puntaje:)
      stub_post_request_calificacion_contenido_inexistente(id_telegram, id_contenido, puntaje)

      expect { described_class.new.calificar_contenido(calificacion) }.to raise_error(ErrorContenidoInexistenteEnAPI)
    end
  end
end
