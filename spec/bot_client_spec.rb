require 'spec_helper'
require 'web_mock'
# Uncomment to use VCR
# require 'vcr_helper'

require_relative '../app/bot_client'

def when_i_send_text(token, message_text)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def when_i_send_text_with_id_telegram(token, message_text, id_telegram)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": id_telegram, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def then_i_get_text(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544', 'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

def stub_get_request_api
  response = { 'version': '0.0.4' }

  stub_request(:get, 'http://fake/version')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_post_request_usuario(email, id_telegram, estado)
  response = { id: 1, email:, id_telegram: }
  stub_request(:post, 'http://fake/usuarios')
    .with(
      body: "{\"email\":\"#{email}\",\"id_telegram\":#{id_telegram}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: estado, body: response.to_json, headers: {})
end

def stub_post_request_usuario_error(email, id_telegram, status, message, field)
  response = {  error: 'Conflicto',
                message:,
                details: {
                  field:
                } }
  stub_request(:post, 'http://fake/usuarios')
    .with(
      body: "{\"email\":\"#{email}\",\"id_telegram\":#{id_telegram}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status:, body: response.to_json, headers: {})
end

def stub_get_request_contenidos_top
  titulos = { "Iron Man": 2008, 'Black Panther': 2018, 'Doctor Strange': 2016 }
  count = 0
  response = titulos.map do |titulo, anio|
    count += 1
    {
      'id' => count,
      'contenido' => {
        'titulo' => titulo,
        'anio' => anio,
        'genero' => 'accion'
      },
      'vistos' => count
    }
  end

  stub_request(:get, 'http://fake/visualizaciones/top?Content-Type=application/json')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_request_contenidos_top_vacio
  response = []

  stub_request(:get, 'http://fake/visualizaciones/top?Content-Type=application/json')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def then_i_get_top_visualizaciones(token)
  text = "Las películas con más visualizaciones son:\n  [ID: 1] Iron Man (accion, 2008)\n  [ID: 2] Black Panther (accion, 2018)\n  [ID: 3] Doctor Strange (accion, 2016)\n"
  then_i_get_text(token, text)
end

def stub_post_request_calificaciones(id_telegram, id_contenido, puntaje, status)
  response = { id: 1, id_telegram:, id_contenido:, puntaje: }

  stub_request(:post, 'http://fake/calificaciones')
    .with(
      body: "{\"id_telegram\":#{id_telegram},\"id_contenido\":#{id_contenido},\"puntaje\":#{puntaje}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status:, body: response.to_json, headers: {})
end

def stub_post_request_calificacion_contenido_no_visto(id_telegram, id_contenido, puntaje)
  response = { error: 'Entidad no procesable', message: '', details: { field: 'visualizacion' } }

  stub_request(:post, 'http://fake/calificaciones')
    .with(
      body: "{\"id_telegram\":#{id_telegram},\"id_contenido\":#{id_contenido},\"puntaje\":#{puntaje}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 422, body: response.to_json, headers: {})
end

def stub_post_request_calificacion_contenido_inexistente(id_telegram, id_contenido, puntaje)
  response = { error: 'No encontrado', message: '', details: { field: 'contenido' } }

  stub_request(:post, 'http://fake/calificaciones')
    .with(
      body: "{\"id_telegram\":#{id_telegram},\"id_contenido\":#{id_contenido},\"puntaje\":#{puntaje}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 404, body: response.to_json, headers: {})
end

def stub_post_request_recalificacion(id_telegram, id_contenido, puntaje, puntaje_anterior)
  response = { id: 1, id_telegram:, id_contenido:, puntaje:, puntaje_anterior: }

  stub_request(:post, 'http://fake/calificaciones')
    .with(
      body: "{\"id_telegram\":#{id_telegram},\"id_contenido\":#{id_contenido},\"puntaje\":#{puntaje}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_post_request_favoritos(id_telegram, id_contenido, estado)
  cuerpo = { id: 1, id_telegram:, id_contenido: }

  stub_request(:post, 'http://fake/favoritos')
    .with(
      body: "{\"id_telegram\":#{id_telegram},\"id_contenido\":#{id_contenido}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: estado, body: cuerpo.to_json, headers: {})
end

def stub_get_request_contenidos_con_ningun_titulo_similar
  response = []

  stub_request(:get, 'http://fake/contenidos?Content-Type=application/json&titulo=Titanic')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_request_contenidos_con_un_titulo_similar
  response = [{ 'id' => 1, 'titulo' => 'Akira', 'anio' => 1988, 'genero' => 'accion' }]

  stub_request(:get, 'http://fake/contenidos?Content-Type=application/json&titulo=Akira')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_request_contenidos_con_dos_titulos_similares
  response = [{ 'id' => 1, 'titulo' => 'Akira', 'anio' => 1988, 'genero' => 'accion' },
              { 'id' => 2, 'titulo' => 'Akira 2', 'anio' => 1990, 'genero' => 'accion' }]

  stub_request(:get, 'http://fake/contenidos?Content-Type=application/json&titulo=Akira')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_request_favoritos_sin_contenidos_faveados
  response = []

  stub_request(:get, 'http://fake/favoritos?Content-Type=application/json&id_telegram=141733544')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_request_favoritos_con_un_contenido_faveado
  response = [{ 'id' => 1, 'titulo' => 'Transformers', 'anio' => 2007, 'genero' => 'accion' }]

  stub_request(:get, 'http://fake/favoritos?Content-Type=application/json&id_telegram=141733544')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_request_contenidos_ultimosagregados_sin_contenido_para_sugerir
  response = []

  stub_request(:get, 'http://fake/contenidos/ultimos-agregados?Content-Type=application/json')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_request_contenidos_ultimosagregados_con_dos_contenidos_para_sugerir
  response = [{ 'id' => 1, 'titulo' => 'Akira', 'anio' => 1988, 'genero' => 'accion' },
              { 'id' => 2, 'titulo' => 'Akira 2', 'anio' => 1990, 'genero' => 'accion' }]

  stub_request(:get, 'http://fake/contenidos/ultimos-agregados?Content-Type=application/json')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_contenidos_id_detalles(status, body, id_contenido)
  stub_request(:get, "http://fake/contenidos/#{id_contenido}/detalles?Content-Type=application/json&id_telegram=141733544")
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status:, body:, headers: {})
end

def stub_get_contenidos_id_detalles_id_invalido(id_contenido)
  body = { 'error' => 'no encontrado' }
  stub_request(:get, "http://fake/contenidos/#{id_contenido}/detalles?Content-Type=application/json&id_telegram=141733544")
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 404, body: body.to_json, headers: {})
end

def stub_get_contenidos_id_detalles_id_no_corresponde_a_omdb(id_contenido)
  body = { 'error' => 'no hay detalles para mostrar' }
  stub_request(:get, "http://fake/contenidos/#{id_contenido}/detalles?Content-Type=application/json&id_telegram=141733544")
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 404, body: body.to_json, headers: {})
end

describe 'BotClient' do
  it 'should get a /version message and respond with current version and team name' do
    token = 'fake_token'
    stub_get_request_api

    when_i_send_text(token, '/version')
    then_i_get_text(token, "version bot: #{Version.current}, version api: 0.0.4")

    BotClient.new(token).run_once
  end

  it 'should get a /start message and respond with Hola' do
    token = 'fake_token'

    when_i_send_text(token, '/start')
    then_i_get_text(token, 'Hola, Emilio')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get an unknown message message and respond with Do not understand' do
    token = 'fake_token'

    when_i_send_text(token, '/unknown')
    then_i_get_text(token, '¿Uh? ¡No te entiendo! ¿Me repetís la pregunta?')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a /registrar message with new user and respond with welcome message' do
    token = 'fake_token'
    stub_post_request_usuario('emilio@gmail.com', 141_733_544, 201)
    when_i_send_text(token, '/registrar emilio@gmail.com')
    then_i_get_text(token, 'Bienvenido, cinéfilo Emilio!')

    BotClient.new(token).run_once
  end

  it 'should get a /registrar message with invalid email and respond with invalid email message' do
    token = 'fake_token'
    when_i_send_text(token, '/registrar emilio')
    then_i_get_text(token, 'Error, tiene que enviar un email válido')

    BotClient.new(token).run_once
  end

  def stub_and_send_primer_usuario(token)
    stub_post_request_usuario('emilio@gmail.com', 1_234_556, 201)
    when_i_send_text_with_id_telegram(token, '/registrar emilio@gmail.com', 1_234_556)
    then_i_get_text(token, 'Bienvenido, cinéfilo Emilio!')
  end

  def stub_and_send_segundo_usuario(token)
    message = 'El telegram ID ya está asociado con una cuenta existente.'
    field = :id_telegram
    stub_post_request_usuario_error('pablito@gmail.com', 1_234_556, 409, message, field)
    when_i_send_text_with_id_telegram(token, '/registrar pablito@gmail.com', 1_234_556)
    then_i_get_text(token, 'Error, tu usuario de telegram ya esta asociado a una cuenta existente')
  end

  def stub_and_send_tercer_usuario(token)
    message = 'El email ya está asociado con una cuenta existente.'
    field = :email
    stub_post_request_usuario_error('emilio@gmail.com', 987_654_3, 409, message, field)
    when_i_send_text_with_id_telegram(token, '/registrar emilio@gmail.com', 987_654_3)
    then_i_get_text(token, 'Error, el email ingresado ya esta asociado a una cuenta existente')
  end

  it 'deberia recibir un mensaje /registrar con número de telegram repetido y responder con un mensaje de error' do
    token = 'fake_token'
    stub_and_send_primer_usuario(token)
    stub_and_send_segundo_usuario(token)
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /registrar con un email ya registrado y responder con un error' do
    token = 'fake_token'
    stub_and_send_primer_usuario(token)
    stub_and_send_tercer_usuario(token)
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /sugerenciasmasvistos y devolver los contenidos más vistos de la plataforma' do
    token = 'fake_token'
    stub_get_request_contenidos_top
    when_i_send_text(token, '/sugerenciasmasvistos')
    then_i_get_top_visualizaciones(token)
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /sugerenciasmasvistos cuando no hay visualizaciones de películas y devolver un mensaje de la situación' do
    token = 'fake_token'
    stub_get_request_contenidos_top_vacio
    when_i_send_text(token, '/sugerenciasmasvistos')
    then_i_get_text(token, 'No hay datos de visualizaciones de películas en el momento')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /calificar {id_contenido} {calificacion} y devolver un mensaje' do
    token = 'fake_token'
    stub_post_request_calificaciones(141_733_544, 97, 4, 201)

    when_i_send_text(token, '/calificar 97 4')
    then_i_get_text(token, 'Calificacion registrada exitosamente')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /calificar {id_contenido} {calificacion} con mensaje de error 422 y decirme que no vi el contenido' do
    token = 'fake_token'
    stub_post_request_calificacion_contenido_no_visto(141_733_544, 97, 4)

    when_i_send_text(token, '/calificar 97 4')
    then_i_get_text(token, '¡Aún no viste este contenido, miralo para poder calificarlo!')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /calificar {id_contenido} {calificacion} con mensaje de error 422 y decirme que la calificación es inválida' do
    token = 'fake_token'

    when_i_send_text(token, '/calificar 97 -1')
    then_i_get_text(token, 'La calificacion es del 1 al 5. ¡Volve a calificar!')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /calificar {id_contenido} {calificacion} con estado 200 y decirme que recalifique' do
    token = 'fake_token'
    stub_post_request_recalificacion(141_733_544, 97, 4, 3)

    when_i_send_text(token, '/calificar 97 4')
    then_i_get_text(token, 'Calificacion actualizada exitosamente')
  end

  it 'deberia recibir un mensaje /calificar {id_contenido} {calificacion} con mensaje de error 404 y decirme que el contenido no existe' do
    token = 'fake_token'
    stub_post_request_calificacion_contenido_inexistente(141_733_544, 97, 4)

    when_i_send_text(token, '/calificar 97 4')
    then_i_get_text(token, 'El contenido ingresado no existe')
  end

  it 'deberia recibir un mensaje /marcarfavorito {id_contenido} y devolver un mensaje de contenido anadido a favoritos' do
    token = 'fake_token'
    stub_post_request_favoritos(141_733_544, 1, 201)
    when_i_send_text(token, '/marcarfavorito 1')
    then_i_get_text(token, 'Contenido añadido a favoritos')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /buscartitulo {titulo} y devolver un mensaje con los resultados de la busqueda cuando no hay coincidencias' do
    token = 'fake_token'
    stub_get_request_contenidos_con_ningun_titulo_similar
    when_i_send_text(token, '/buscartitulo Titanic')
    then_i_get_text(token, 'No se encontraron resultados para la búsqueda')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /buscartitulo {titulo} y devolver un mensaje con los resultados de la búsqueda cuando hay una coincidencia' do
    token = 'fake_token'
    stub_get_request_contenidos_con_un_titulo_similar
    when_i_send_text(token, '/buscartitulo Akira')
    result = "Acá están los titulos que coinciden con tu busqueda:\n- [ID: 1] Akira (accion, 1988)\n"
    then_i_get_text(token, result)
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /buscartitulo {titulo} y devolver un mensaje con los resultados de la búsqueda cuando hay varias coincidencias' do
    token = 'fake_token'
    stub_get_request_contenidos_con_dos_titulos_similares
    when_i_send_text(token, '/buscartitulo Akira')
    result = "Acá están los titulos que coinciden con tu busqueda:\n- [ID: 1] Akira (accion, 1988)\n- [ID: 2] Akira 2 (accion, 1990)\n"
    then_i_get_text(token, result)
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /misfavoritos y devolver un mensaje diciendo que el usuario no tiene favoritos' do
    token = 'fake_token'
    stub_get_request_favoritos_sin_contenidos_faveados
    when_i_send_text(token, '/misfavoritos')
    then_i_get_text(token, 'Parece que no tienes favoritos! Empieza a marcar tus contenidos como favoritos para verlos aquí.')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /misfavoritos y devolver un mensaje cuando un usuario tiene una película como favorita' do
    token = 'fake_token'
    stub_get_request_favoritos_con_un_contenido_faveado
    when_i_send_text(token, '/misfavoritos')
    result = "Aquí tienes tu listado de favoritos:\n- [ID: 1] Transformers (accion, 2007)\n"
    then_i_get_text(token, result)
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /contenidos/ultimos-agregados y devolver un mensaje con una lista vacía' do
    token = 'fake_token'
    stub_get_request_contenidos_ultimosagregados_sin_contenido_para_sugerir
    when_i_send_text(token, '/sugerenciasnuevos')
    then_i_get_text(token, '¡No hay nuevos contenidos esta semana, estate atento a las novedades!')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /contenidos/ultimos-agregados y devolver un mensaje con una lista de sugerencias' do
    token = 'fake_token'
    stub_get_request_contenidos_ultimosagregados_con_dos_contenidos_para_sugerir
    when_i_send_text(token, '/sugerenciasnuevos')
    result = "Acá tienes algunas sugerencias:\n- [ID: 1] Akira (accion, 1988)\n- [ID: 2] Akira 2 (accion, 1990)\n"
    then_i_get_text(token, result)
    BotClient.new(token).run_once
  end

  def response_get_contenidos_id_detalles
    {
      'titulo' => 'Iron Man',
      'anio' => 2008,
      'premios' => 'Nominated for 2 Oscars. 24 wins & 73 nominations total',
      'director' => 'Jon Favreau',
      'sinopsis' => 'After being held captive in an Afghan cave, billionaire engineer Tony Stark creates a unique weaponized suit of armor to fight evil'
    }
  end

  def response_incompleta_get_contenidos_id_detalles
    {
      'titulo' => 'Iron Man',
      'anio' => 2008,
      'premios' => 'Nominated for 2 Oscars. 24 wins & 73 nominations total',
      'sinopsis' => 'After being held captive in an Afghan cave, billionaire engineer Tony Stark creates a unique weaponized suit of armor to fight evil'
    }
  end

  def response_get_contenidos_id_detalles_no_visto
    {
      'fue_visto' => false,
      'titulo' => 'Iron Man',
      'anio' => 2008,
      'premios' => 'Nominated for 2 Oscars. 24 wins & 73 nominations total',
      'director' => 'Jon Favreau',
      'sinopsis' => 'After being held captive in an Afghan cave, billionaire engineer Tony Stark creates a unique weaponized suit of armor to fight evil'
    }
  end

  def response_get_contenidos_id_detalles_visto
    {
      'fue_visto' => true,
      'titulo' => 'Iron Man',
      'anio' => 2008,
      'premios' => 'Nominated for 2 Oscars. 24 wins & 73 nominations total',
      'director' => 'Jon Favreau',
      'sinopsis' => 'After being held captive in an Afghan cave, billionaire engineer Tony Stark creates a unique weaponized suit of armor to fight evil'
    }
  end

  def then_i_get_masinfo(token, detalles_contenido, id_contenido)
    text = "Info de #{detalles_contenido['titulo']} (#{id_contenido}):\n- "
    if detalles_contenido.key?('fue_visto')
      visto_text = detalles_contenido['fue_visto'] ? '¡Ya lo viste!' : '¡No lo viste!'
      text << "#{visto_text}\n- "
    end
    text << "Anio: #{detalles_contenido['anio']}\n- "
    text << "Premios: #{detalles_contenido['premios']}\n- "
    text << "Director: #{detalles_contenido['director']}\n- "
    text << "Sinopsis: #{detalles_contenido['sinopsis']}\n"

    then_i_get_text(token, text)
  end

  def then_i_get_incomplete_masinfo(token, detalles_contenido, id_contenido)
    text = "Info de #{detalles_contenido['titulo']} (#{id_contenido}):\n- "
    text << "Anio: #{detalles_contenido['anio']}\n- "
    text << "Premios: #{detalles_contenido['premios']}\n- "
    text << "Director: No disponible\n- "
    text << "Sinopsis: #{detalles_contenido['sinopsis']}\n"

    then_i_get_text(token, text)
  end

  it 'deberia recibir un mensaje /masinfo {id_contenido} y devolver un mensaje con mas detalles sobre ese contenido' do
    token = 'fake_token'
    detalles_contenido = response_get_contenidos_id_detalles
    id_contenido = 1

    stub_get_contenidos_id_detalles(200, detalles_contenido.to_json, id_contenido)

    when_i_send_text(token, "/masinfo #{id_contenido}")
    then_i_get_masinfo(token, detalles_contenido, id_contenido)

    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /masinfo {id_contenido} con id_contenido invalido y devolver un mensaje de error' do
    token = 'fake_token'

    id_contenido = -1

    stub_get_contenidos_id_detalles_id_invalido(id_contenido)

    when_i_send_text(token, "/masinfo #{id_contenido}")
    then_i_get_text(token, 'No se encontraron resultados para el contenido buscado')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /masinfo {id_contenido} con id_contenido no en la base de datos y devolver un mensaje de error' do
    token = 'fake_token'

    id_contenido = '2'

    stub_get_contenidos_id_detalles_id_invalido(id_contenido)

    when_i_send_text(token, "/masinfo #{id_contenido}")
    then_i_get_text(token, 'No se encontraron resultados para el contenido buscado')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /masinfo {id_contenido} con id_contenido no en omdb y devolver un mensaje de error' do
    token = 'fake_token'

    id_contenido = '2'

    stub_get_contenidos_id_detalles_id_no_corresponde_a_omdb(id_contenido)

    when_i_send_text(token, "/masinfo #{id_contenido}")
    then_i_get_text(token, 'No se encontraron detalles para el contenido buscado')
    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /masinfo {id_contenido} con id_contenido en OMDb pero con campos faltantes y la api se encargará de no mostrarlos' do
    token = 'fake_token'
    detalles_contenido = response_incompleta_get_contenidos_id_detalles
    id_contenido = 1

    stub_get_contenidos_id_detalles(200, detalles_contenido.to_json, id_contenido)

    when_i_send_text(token, "/masinfo #{id_contenido}")
    then_i_get_incomplete_masinfo(token, detalles_contenido, id_contenido)

    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /masinfo {id_contenido} con id_contenido en imbd y con telegram id y ver que dice no visto' do
    token = 'fake_token'
    detalles_contenido = response_get_contenidos_id_detalles_no_visto
    id_contenido = 1

    stub_get_contenidos_id_detalles(200, detalles_contenido.to_json, id_contenido)

    when_i_send_text(token, "/masinfo #{id_contenido}")
    then_i_get_masinfo(token, detalles_contenido, id_contenido)

    BotClient.new(token).run_once
  end

  it 'deberia recibir un mensaje /masinfo {id_contenido} con id_contenido en imbd y con telegram id y ver que dice visto' do
    token = 'fake_token'
    detalles_contenido = response_get_contenidos_id_detalles_visto
    id_contenido = 1

    stub_get_contenidos_id_detalles(200, detalles_contenido.to_json, id_contenido)

    when_i_send_text(token, "/masinfo #{id_contenido}")
    then_i_get_masinfo(token, detalles_contenido, id_contenido)

    BotClient.new(token).run_once
  end

  def then_i_get_mensaje_de_ayuda(token)
    text = "Sé responder los siguientes mensajes:
- /version: Devuelve la versión en la que el Bot está corriendo
- /registrar <email>: Registra tu usuario de telegram asignandole un email
- /sugerenciasmasvistos: Devuelve una lista con los 3 contenidos mas vistos de toda la plataforma
- /calificar <id_contenido> <calificacion>: Si estas registrado podes calificar con una calificacion del 1 al 5 cualquier contenido
- /marcarfavorito <id_contenido>: Si estas registrado podes marcar un contenido como favorito
- /buscartitulo <titulo>: Devuelve todos los contenidos en nuestra bases de datos que sean similares a tu busqueda
- /misfavoritos: Si estas registrado, devuelve tu lista de favoritos
- /sugerenciasnuevos: Devuelve una lista con los 5 contenidos mas nuevos de la ultima semana
- /masinfo <id_contenido>: Devuelve informacion extra acerca del contenido - director, premios, sinopsis"

    then_i_get_text(token, text)
  end

  it 'deberia recibir un mensaje /ayuda y ver que devuelve un texto explicando todos los comandos que sabe responder el bot' do
    token = 'fake_token'

    when_i_send_text(token, '/ayuda')
    then_i_get_mensaje_de_ayuda(token)

    BotClient.new(token).run_once
  end
end
