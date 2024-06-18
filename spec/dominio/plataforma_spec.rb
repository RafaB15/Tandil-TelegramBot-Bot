require 'spec_helper'
Dir[File.join(__dir__, '../../dominio/', '*.rb')].each { |file| require file }

require 'rspec'

describe Plataforma do
  describe 'registrar_usuario' do
    let(:conector_api) { instance_double('ConectorAPI', registrar_usuario: nil) }
    let(:usuario) { instance_double('Usuario') }

    it 'deberia crear un usuario y enviar un request a la APIRest para crear un usuario' do
      email = 'juan@gmail.com'
      id_telegram = 123_456_789

      allow(Usuario).to receive(:new).and_return(usuario)
      expect(Usuario).to receive(:new).with(email, id_telegram)
      expect(conector_api).to receive(:registrar_usuario).with(usuario)

      plataforma = described_class.new(conector_api)
      plataforma.registrar_usuario(email, id_telegram)
    end
  end

  describe 'calificar_contenido' do
    let(:conector_api) { instance_double('ConectorAPI', calificar_contenido: nil) }
    let(:calificacion) { instance_double('Calificacion') }

    it 'deberia crear una calificacion y enviar un request a la APIRest para persistirla' do
      id_telegram = 123_456_789
      id_contenido = 40
      puntaje = 4

      allow(Calificacion).to receive(:new).and_return(calificacion)
      expect(Calificacion).to receive(:new).with(id_telegram, id_contenido, puntaje)
      expect(conector_api).to receive(:calificar_contenido).with(calificacion)

      plataforma = described_class.new(conector_api)
      plataforma.calificar_contenido(id_telegram, id_contenido, puntaje)
    end
  end
end
