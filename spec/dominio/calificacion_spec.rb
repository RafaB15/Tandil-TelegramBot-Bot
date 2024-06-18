require 'spec_helper'
require_relative '../../dominio/calificacion'

describe Calificacion do
  subject(:usuario) { described_class.new(123_456_789, 25, 4) }

  describe 'modelo' do
    it { is_expected.to respond_to(:id_telegram) }
    it { is_expected.to respond_to(:id_contenido) }
    it { is_expected.to respond_to(:puntaje) }
  end

  describe 'new' do
    it 'debe levantar un error cuando el puntaje no es menor a 0' do
      expect { described_class.new(123_456_789, 25, -1) }.to raise_error(ErrorAlInstanciarCalificacionInvalida)
    end

    it 'debe levantar un error cuando el puntaje no es mayor a 5' do
      expect { described_class.new(123_456_789, 25, 6) }.to raise_error(ErrorAlInstanciarCalificacionInvalida)
    end
  end
end
