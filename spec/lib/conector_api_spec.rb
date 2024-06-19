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
    it 'Deberia enviar los datos de un usuario para registrarlos en la API y devolver exito 201' do
      email = 'juan@gmail.com'
      id_telegram = 123_456_789
      estado = 201

      usuario = instance_double(Usuario, email:, id_telegram:)
      stub_post_request_usuario(email, id_telegram, estado)

      respuesta = described_class.new.registrar_usuario(usuario)

      expect(respuesta.status).to eq estado
    end

    it 'Deberia enviar los datos de un usuario con email invalido y devolver un estado 422' do
      email = 'juan'
      id_telegram = 123_456_789
      estado = 422

      usuario = instance_double(Usuario, email:, id_telegram:)
      stub_post_request_usuario(email, id_telegram, estado)

      respuesta = described_class.new.registrar_usuario(usuario)

      expect(respuesta.status).to eq estado
    end

    it 'Deberia enviar los datos de un usuario con un ID de Telegram ya en uso y devolver un estado 409 con field id telegram' do
      id_telegram = 123_456_789

      usuario = instance_double(Usuario, email: 'juan@gmail.com', id_telegram:)
      stub_post_request_usuario('juan@gmail.com', id_telegram, 201)
      described_class.new.registrar_usuario(usuario)

      field = 'id_telegram'
      usuario = instance_double(Usuario, email: 'pablito@gmail.com', id_telegram:)
      stub_post_request_usuario_error('pablito@gmail.com', id_telegram, 409, 'El telegram ID ya está asociado con una cuenta existente.', field)

      respuesta = described_class.new.registrar_usuario(usuario)

      expect(respuesta.status).to eq 409
      expect(JSON.parse(respuesta.body)['details']['field']).to eq field
    end

    it 'Deberia enviar los datos de un usuario con un email ya en uso y devolver un estado 409 con field email' do
      email = 'juan@gmail.com'

      usuario = instance_double(Usuario, email:, id_telegram: 123_456_789)
      stub_post_request_usuario(email, 123_456_789, 201)
      described_class.new.registrar_usuario(usuario)

      field = 'email'
      usuario = instance_double(Usuario, email:, id_telegram: 987_654_321)
      stub_post_request_usuario_error(email, 987_654_321, 409, 'El email ya está asociado con una cuenta existente.', field)

      respuesta = described_class.new.registrar_usuario(usuario)

      expect(respuesta.status).to eq 409
      expect(JSON.parse(respuesta.body)['details']['field']).to eq field
    end
  end

  describe 'calificar_contenido' do
    it 'Deberia enviar los datos de una calificacion para registrarlos en la API y devolver exito 201' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4
      estado = 201

      calificacion = instance_double(Calificacion, id_telegram:, id_contenido:, puntaje:)
      stub_post_request_calificaciones(id_telegram, id_contenido, puntaje, estado)

      respuesta = described_class.new.calificar_contenido(calificacion)

      expect(respuesta.status).to eq estado
    end

    it 'Deberia enviar los datos de una calificacion y se recibe un error con estado 500' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4
      estado = 500

      calificacion = instance_double(Calificacion, id_telegram:, id_contenido:, puntaje:)
      stub_post_request_calificaciones(id_telegram, id_contenido, puntaje, estado)

      respuesta = described_class.new.calificar_contenido(calificacion)

      expect(respuesta.status).to eq estado
    end
  end

  describe 'marcar_contenido_como_favorito' do
    it 'Deberia enviar los datos de un contenido faveado para registrarlo en la API y devolver exito' do
      id_telegram = 123_456_789
      id_contenido = 24
      estado = 201

      favorito = instance_double(Favorito, id_telegram:, id_contenido:)
      stub_post_request_favoritos(id_telegram, id_contenido, estado)

      respuesta = described_class.new.marcar_contenido_como_favorito(favorito)

      expect(respuesta.status).to eq estado
    end
  end

  describe 'obtener_favoritos' do
    it 'Deberia pedir mis contenidos favoritos y si no tengo, recibir una respuesta con status 200' do
      id_telegram = 141_733_544
      estado = 200

      stub_get_request_favoritos_sin_contenidos_faveados

      respuesta = described_class.new.obtener_favoritos(id_telegram)
      favoritos = JSON.parse(respuesta.body)

      expect(favoritos.empty?).to eq true
      expect(respuesta.status).to eq estado
    end

    it 'Deberia pedir mis contenidos favoritos y recibir una respuesta con status 200' do
      id_telegram = 141_733_544
      estado = 200

      stub_get_request_favoritos_con_un_contenido_faveado

      respuesta = described_class.new.obtener_favoritos(id_telegram)
      favoritos = JSON.parse(respuesta.body)

      expect(favoritos.empty?).to eq false
      expect(respuesta.status).to eq estado
    end
  end

  describe 'buscar_contenido_por_titulo' do
    it 'Deberia buscar contenidos por titulo y si la BDD de la API no encuentra ningun titulo similar, recibir una respuesta con status 200 y una lista vacia' do
      titulo = 'Titanic'
      estado = 200

      stub_get_request_contenidos_con_ningun_titulo_similar

      respuesta = described_class.new.buscar_contenido_por_titulo(titulo)
      contenidos_favoritos = JSON.parse(respuesta.body)

      expect(contenidos_favoritos.empty?).to eq true
      expect(respuesta.status).to eq estado
    end

    it 'Deberia pedir mis contenidos favoritos y recibir una respuesta con status 200' do
      titulo = 'Akira'
      estado = 200

      stub_get_request_contenidos_con_un_titulo_similar

      respuesta = described_class.new.buscar_contenido_por_titulo(titulo)
      contenidos_favoritos = JSON.parse(respuesta.body)

      expect(contenidos_favoritos.empty?).to eq false
      expect(respuesta.status).to eq estado
    end
  end
end
