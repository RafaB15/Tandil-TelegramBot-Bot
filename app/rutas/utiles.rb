require_relative '../../lib/routing'
require_relative '../../lib/conector_api'
require_relative '../../dominio/plataforma'

def generar_lista_de_contenidos(contenidos)
  respuesta = ''

  contenidos.each do |contenido|
    id_contenido = contenido['id']
    titulo = contenido['titulo']
    anio = contenido['anio']
    genero = contenido['genero']

    respuesta += "- [ID: #{id_contenido}] #{titulo} (#{genero}, #{anio})\n"
  end

  respuesta
end
