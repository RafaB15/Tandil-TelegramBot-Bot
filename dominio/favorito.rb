class Favorito
  attr_reader :id_telegram, :id_contenido

  def initialize(id_telegram, id_contenido)
    @id_telegram = id_telegram
    @id_contenido = id_contenido
  end
end
