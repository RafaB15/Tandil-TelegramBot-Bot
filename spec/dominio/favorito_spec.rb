require 'spec_helper'
require_relative '../../dominio/favorito'

describe Favorito do
  subject(:favorito) { described_class.new(123_456_789, 55) }

  describe 'modelo' do
    it { is_expected.to respond_to(:id_telegram) }
    it { is_expected.to respond_to(:id_contenido) }
  end
end
