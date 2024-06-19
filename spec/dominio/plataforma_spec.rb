require 'spec_helper'
Dir[File.join(__dir__, '../../dominio/', '*.rb')].each { |file| require file }
require_relative '../../lib/conector_api'

require 'rspec'

describe Plataforma do
  describe 'registrar_usuario' do
    let(:usuario) { instance_double('Usuario') }

    before(:each) { allow(Usuario).to receive(:new).and_return(usuario) }

    it 'deberia crear un usuario y enviar una request a la APIRest para crear un usuario' do
      respuesta = instance_double('RespuestaFaraday', status: 201, body: {}.to_json)
      conector_api = instance_double('ConectorAPI', registrar_usuario: respuesta)
      email = 'juan@gmail.com'
      id_telegram = 123_456_789

      expect(Usuario).to receive(:new).with(email, id_telegram)
      expect(conector_api).to receive(:registrar_usuario).with(usuario)

      plataforma = described_class.new(conector_api)
      plataforma.registrar_usuario(email, id_telegram)
    end

    it 'Deberia enviar los datos de un usuario con email valido y levantar un error de I/O por una respuesta de error de email de la API (Caso raro)' do
      respuesta = instance_double('RespuestaFaraday', status: 500, body: {}.to_json)
      conector_api = instance_double('ConectorAPI', registrar_usuario: respuesta)
      email = 'juan@gmail.com'
      id_telegram = 123_456_789

      plataforma = described_class.new(conector_api)
      expect { plataforma.registrar_usuario(email, id_telegram) }.to raise_error(IOError)
    end

    it 'Deberia enviar los datos de un usuario con email invalido y levantar un error de Error al instanciar un usuario con email invalidos' do
      conector_api = instance_double('ConectorApi')
      email = 'juan@gmail.com'
      id_telegram = 123_456_789

      allow(Usuario).to receive(:new).and_raise(ErrorAlInstanciarUsuarioEmailInvalido)

      plataforma = described_class.new(conector_api)
      expect { plataforma.registrar_usuario(email, id_telegram) }.to raise_error(ErrorAlInstanciarUsuarioEmailInvalido)
    end

    it 'Deberia enviar los datos de un usuario con un ID de Telegram ya en uso y levantar un error de ID Telegram ya asociado a una cuenta' do
      body = { 'details' => { 'field' => 'id_telegram' } }
      respuesta = instance_double('RespuestaFaraday', status: 409, body: body.to_json)
      conector_api = instance_double('ConectorAPI', registrar_usuario: respuesta)
      email = 'juan@gmail.com'
      id_telegram = 123_456_789

      plataforma = described_class.new(conector_api)
      expect { plataforma.registrar_usuario(email, id_telegram) }.to raise_error(ErrorIDTelegramYaAsociadoAUnaCuentaExistenteEnLaAPI)
    end

    it 'Deberia enviar los datos de un usuario con un email ya en uso y levantar un error de email ya asociado a una cuenta' do
      body = { 'details' => { 'field' => 'email' } }
      respuesta = instance_double('RespuestaFaraday', status: 409, body: body.to_json)
      conector_api = instance_double('ConectorAPI', registrar_usuario: respuesta)
      email = 'juan@gmail.com'
      id_telegram = 123_456_789

      plataforma = described_class.new(conector_api)
      expect { plataforma.registrar_usuario(email, id_telegram) }.to raise_error(ErrorEmailYaAsociadoAUnaCuentaExistenteEnLaAPI)
    end
  end

  describe 'calificar_contenido' do
    let(:conector_api) { instance_double('ConectorAPI', calificar_contenido: nil) }
    let(:calificacion) { instance_double('Calificacion') }

    it 'deberia crear una calificacion y enviar una request a la APIRest para persistirla' do
      allow(Calificacion).to receive(:new).and_return(calificacion)
      respuesta = instance_double('RespuestaFaraday', status: 201, body: {}.to_json)
      conector_api = instance_double('ConectorAPI', calificar_contenido: respuesta)
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4

      expect(Calificacion).to receive(:new).with(id_telegram, id_contenido, puntaje)
      expect(conector_api).to receive(:calificar_contenido).with(calificacion)

      plataforma = described_class.new(conector_api)
      plataforma.calificar_contenido(id_telegram, id_contenido, puntaje)
    end

    it 'Deberia enviar los datos de una calificacion no vista aun por el usuario de telegram y levantar un error de usuario no vio el contenido' do
      allow(Calificacion).to receive(:new).and_return(calificacion)
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4

      body = { 'details' => { 'field' => 'visualizacion' } }
      respuesta = instance_double('RespuestaFaraday', status: 422, body: body.to_json)
      conector_api = instance_double('ConectorAPI', calificar_contenido: respuesta)

      plataforma = described_class.new(conector_api)

      expect { plataforma.calificar_contenido(id_telegram, id_contenido, puntaje) }.to raise_error(ErrorAlPedirCalificacionContenidoNoVistoPorUsuarioDeTelegram)
    end

    it 'Deberia enviar los datos de una calificacion con un puntaje negativo y levantar un error de puntaje invalido' do
      allow(Calificacion).to receive(:new).and_return(calificacion)
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4

      body = { 'details' => { 'field' => 'calificacion' } }
      respuesta = instance_double('RespuestaFaraday', status: 422, body: body.to_json)
      conector_api = instance_double('ConectorAPI', calificar_contenido: respuesta)

      plataforma = described_class.new(conector_api)

      expect { plataforma.calificar_contenido(id_telegram, id_contenido, puntaje) }.to raise_error(ErrorAlInstanciarCalificacionPuntajeInvalido)
    end

    it 'Deberia enviar nuevos datos para registrar una calificacion ya calificada y devolver una calificacion con el puntaje anterior' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4
      puntaje_anterior = 3

      body = { 'puntaje_anterior' => puntaje_anterior }
      respuesta = instance_double('RespuestaFaraday', status: 200, body: body.to_json)
      conector_api = instance_double('ConectorAPI', calificar_contenido: respuesta)

      plataforma = described_class.new(conector_api)
      calificacion_anterior = plataforma.calificar_contenido(id_telegram, id_contenido, puntaje)

      expect(calificacion_anterior.puntaje).to eq puntaje_anterior
    end

    it 'Deberia enviar los datos de una calificacion con un contenido que no esta en la base de datos de la API y levantar un error de contenido inexistente' do
      allow(Calificacion).to receive(:new).and_return(calificacion)
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4

      body = { 'details' => { 'field' => 'contenido' } }
      respuesta = instance_double('RespuestaFaraday', status: 404, body: body.to_json)
      conector_api = instance_double('ConectorAPI', calificar_contenido: respuesta)

      plataforma = described_class.new(conector_api)

      expect { plataforma.calificar_contenido(id_telegram, id_contenido, puntaje) }.to raise_error(ErrorContenidoInexistenteEnAPI)
    end
  end

  describe 'marcar_contenido_como_favorito' do
    let(:favorito) { instance_double('Favorito') }

    before(:each) { allow(Favorito).to receive(:new).and_return(favorito) }

    it 'deberia crear un favorito y enviar una request a la APIRest para persistirla y recibir un estado de exito' do
      respuesta = instance_double('RespuestaFaraday', status: 201)
      conector_api = instance_double('ConectorAPI', marcar_contenido_como_favorito: respuesta)
      id_telegram = 123_456_789
      id_contenido = 55

      expect(Favorito).to receive(:new).with(id_telegram, id_contenido)
      expect(conector_api).to receive(:marcar_contenido_como_favorito).with(favorito)

      plataforma = described_class.new(conector_api)
      plataforma.marcar_contenido_como_favorito(id_telegram, id_contenido)
    end

    it 'deberia crear un favorito y enviar una request a la APIRest para persistirla, si hubo un error, deberia devolver un error IO' do
      respuesta = instance_double('RespuestaFaraday', status: 500)
      conector_api = instance_double('ConectorAPI', marcar_contenido_como_favorito: respuesta)
      id_telegram = 123_456_789
      id_contenido = 55

      expect(Favorito).to receive(:new).with(id_telegram, id_contenido)
      expect(conector_api).to receive(:marcar_contenido_como_favorito).with(favorito)

      plataforma = described_class.new(conector_api)
      expect { plataforma.marcar_contenido_como_favorito(id_telegram, id_contenido) }.to raise_error(IOError)
    end
  end

  describe 'obtener_favoritos' do
    let(:conector_api) { instance_double('ConectorAPI') }

    it 'deberia pedir mis favoritos y si no tengo, levantar un error de IO' do
      respuesta = instance_double('RespuestaFaraday', body: [].to_json)
      id_telegram = 141_733_544

      allow(conector_api).to receive(:obtener_favoritos).and_return(respuesta)
      expect(conector_api).to receive(:obtener_favoritos).with(id_telegram)

      plataforma = described_class.new(conector_api)

      expect { plataforma.obtener_favoritos(id_telegram) }.to raise_error(IOError)
    end

    it 'deberia pedir mis favoritos y obtener una lista de ellos' do
      favorito = { 'id' => 1, 'titulo' => 'Transformers', 'anio' => 2007, 'genero' => 'accion' }
      respuesta = instance_double('RespuestaFaraday', body: [favorito].to_json)

      id_telegram = 141_733_544

      allow(conector_api).to receive(:obtener_favoritos).and_return(respuesta)
      expect(conector_api).to receive(:obtener_favoritos).with(id_telegram)

      plataforma = described_class.new(conector_api)
      favoritos = plataforma.obtener_favoritos(id_telegram)

      expect(favoritos).to eq [favorito]
    end
  end

  describe 'obtener_mas_vistos' do
    let(:conector_api) { instance_double('ConectorAPI') }

    it 'deberia pedir los mas vistos y si no hay, arrojar error de IO' do
      respuesta = instance_double('RespuestaFaraday', body: [].to_json)

      allow(conector_api).to receive(:obtener_sugerencias_contenidos_mas_vistos).and_return(respuesta)
      expect(conector_api).to receive(:obtener_sugerencias_contenidos_mas_vistos)

      plataforma = described_class.new(conector_api)

      expect { plataforma.obtener_mas_vistos }.to raise_error(IOError)
    end

    it 'deberia pedir los mas vistos y obtener una lista de ellos' do
      mas_visto = { 'id' => 516, 'contenido' => { 'titulo' => 'Nahir', 'anio' => 2024, 'genero' => 'drama' }, 'vistas' => 3 }
      respuesta = instance_double('RespuestaFaraday', body: [mas_visto].to_json)

      allow(conector_api).to receive(:obtener_sugerencias_contenidos_mas_vistos).and_return(respuesta)
      expect(conector_api).to receive(:obtener_sugerencias_contenidos_mas_vistos)

      plataforma = described_class.new(conector_api)
      mas_vistos = plataforma.obtener_mas_vistos

      expect(mas_vistos).to eq [mas_visto]
    end
  end

  describe 'obtener_mas_nuevos' do
    let(:conector_api) { instance_double('ConectorAPI') }

    it 'deberia pedir los mas nuevos y si no hay, arrojar error de IO' do
      respuesta = instance_double('RespuestaFaraday', body: [].to_json)

      allow(conector_api).to receive(:obtener_sugerencias_contenidos_mas_nuevos).and_return(respuesta)
      expect(conector_api).to receive(:obtener_sugerencias_contenidos_mas_nuevos)

      plataforma = described_class.new(conector_api)

      expect { plataforma.obtener_mas_nuevos }.to raise_error(IOError)
    end

    it 'deberia pedir los mas nuevos y obtener una lista de ellos' do
      mas_nuevo = { 'id' => 764, 'titulo' => 'Aurora', 'anio' => 1989, 'genero' => 'drama' }
      respuesta = instance_double('RespuestaFaraday', body: [mas_nuevo].to_json)

      allow(conector_api).to receive(:obtener_sugerencias_contenidos_mas_nuevos).and_return(respuesta)
      expect(conector_api).to receive(:obtener_sugerencias_contenidos_mas_nuevos)

      plataforma = described_class.new(conector_api)
      mas_nuevos = plataforma.obtener_mas_nuevos

      expect(mas_nuevos).to eq [mas_nuevo]
    end
  end
end
