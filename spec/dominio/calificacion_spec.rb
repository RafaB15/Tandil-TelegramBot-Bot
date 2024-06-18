require 'spec_helper'
require_relative '../../dominio/calificacion'

describe Calificacion do
  subject(:calificacion) { described_class.new(123_456_789, 25, 4) }

  describe 'modelo' do
    it { is_expected.to respond_to(:id_telegram) }
    it { is_expected.to respond_to(:id_contenido) }
    it { is_expected.to respond_to(:puntaje) }
  end

  describe 'new' do
    it 'debe levantar un error cuando el puntaje es menor a 0' do
      expect { described_class.new(123_456_789, 25, -1) }.to raise_error(ErrorAlInstanciarCalificacionPuntajeInvalido)
    end

    it 'debe levantar un error cuando el puntaje es mayor a 5' do
      expect { described_class.new(123_456_789, 25, 6) }.to raise_error(ErrorAlInstanciarCalificacionPuntajeInvalido)
    end
  end

  describe 'recalificar' do
    let(:calificacion) { described_class.new(123_456_789, 25, 4) }

    it 'debe recalifica correctamente si se le pasa un puntaje valido' do
      expect(calificacion.recalificar(3)).to eq 4
      expect(calificacion.puntaje).to eq 3
    end

    it 'debe levantar un error cuando recalifica y el puntaje es menor a 0' do
      expect { calificacion.recalificar(-1) }.to raise_error(ErrorAlInstanciarCalificacionPuntajeInvalido)
    end

    it 'debe levantar un error cuando recalifica y el puntaje es mayor a 5' do
      expect { calificacion.recalificar(6) }.to raise_error(ErrorAlInstanciarCalificacionPuntajeInvalido)
    end
  end
end
