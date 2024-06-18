require 'spec_helper'
require_relative '../../dominio/usuario'

describe Usuario do
  subject(:usuario) { described_class.new('email@gmail.com', 123_456_789) }

  describe 'modelo' do
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:id_telegram) }
  end

  describe 'new' do
    it 'debe levantar un error cuando el email no es valido' do
      expect { described_class.new('gmail.com', 123_456_789) }.to raise_error(ErrorAlInstanciarUsuarioEmailInvalido)
    end
  end
end
