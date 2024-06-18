require 'spec_helper'
require_relative '../../dominio/Plataforma'
require_relative '../../dominio/usuario'

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
end
