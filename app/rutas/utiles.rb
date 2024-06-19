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

def manejar_error(mapa_de_errores, error)
  if mapa_de_errores.key?(error.class.name)
    mapa_de_errores[error.class.name]
  else
    mapa_de_errores['ErrorPredeterminado']
  end
end
