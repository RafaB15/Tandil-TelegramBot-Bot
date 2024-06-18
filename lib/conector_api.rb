require 'faraday'

class ConectorApi
  API_REST_URL = ENV['API_URL']

  def obtener_version
    Faraday.get("#{API_REST_URL}/version")
  end

  def registrar_usuario(usuario)
    cuerpo = { email: usuario.email, id_telegram: usuario.id_telegram }

    Faraday.post("#{API_REST_URL}/usuarios", cuerpo.to_json, 'Content-Type' => 'application/json')
  end

  def calificar_contenido(calificacion)
    cuerpo = { id_telegram: calificacion.id_telegram, id_contenido: calificacion.id_contenido, puntaje: calificacion.puntaje }

    Faraday.post("#{API_REST_URL}/calificaciones", cuerpo.to_json, 'Content-Type' => 'application/json')
  end

  def marcar_contenido_como_favorito(favorito)
    cuerpo = { id_telegram: favorito.id_telegram, id_contenido: favorito.id_contenido }

    Faraday.post("#{API_REST_URL}/favoritos", cuerpo.to_json, 'Content-Type' => 'application/json')
  end

  def obtener_favoritos(id_telegram)
    Faraday.get("#{API_REST_URL}/favoritos", id_telegram:, 'Content-Type' => 'application/json')
  end

  def obtener_sugerencias_contenidos_mas_nuevos
    Faraday.get("#{API_REST_URL}/contenidos/ultimos-agregados", 'Content-Type' => 'application/json')
  end

  def obtener_sugerencias_contenidos_mas_vistos
    Faraday.get("#{API_REST_URL}/visualizaciones/top", 'Content-Type' => 'application/json')
  end

  def buscar_contenido_por_titulo(titulo)
    Faraday.get("#{API_REST_URL}/contenidos", titulo:, 'Content-Type' => 'application/json')
  end

  def obtener_detalles_de_contenido(id_contenido, id_telegram)
    Faraday.get("#{API_REST_URL}/contenidos/#{id_contenido}/detalles", id_telegram:, 'Content-Type' => 'application/json')
  end
end
