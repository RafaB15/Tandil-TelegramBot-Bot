require 'spec_helper'
require 'web_mock'
# Uncomment to use VCR
# require 'vcr_helper'

require "#{File.dirname(__FILE__)}/../app/bot_client"

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

def stub_post_request_usuario(email, id_telegram, status)
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
    .to_return(status:, body: response.to_json, headers: {})
end

def stub_post_request_usuario_error(email, id_telegram, status, message, field)
  response = {  error: 'Conflicto',
                message:,
                field: }
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

def stub_get_top_visualizaciones
  titulos = { "Iron Man": 2008, 'Black Panther': 2018, 'Doctor Strange': 2016 }
  count = 0
  response = titulos.map do |titulo, anio|
    count += 1
    {
      'id' => count,
      'pelicula' => {
        'titulo' => titulo,
        'anio' => anio,
        'genero' => 'accion'
      },
      'vistos' => count
    }
  end

  stub_request(:get, 'http://fake/visualizacion/top?Content-Type=application/json')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_empty_top_visualizaciones
  response = []

  stub_request(:get, 'http://fake/visualizacion/top?Content-Type=application/json')
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

def stub_post_request_calificacion(id_telegram, id_pelicula, calificacion, status)
  response = { id: 1, id_telegram:, id_pelicula:, calificacion: }

  stub_request(:post, 'http://fake/calificacion')
    .with(
      body: "{\"id_telegram\":#{id_telegram},\"id_pelicula\":#{id_pelicula},\"calificacion\":#{calificacion}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status:, body: response.to_json, headers: {})
end

def stub_post_request_marcar_favorita(email, id_contenido, _status)
  _response = { id: 1, email:, id_contenido: }
  stub_request(:post, 'http://fake/favorito')
    .with(
      body: '{"id_telegram":141733544,"id_contenido":1}',
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 201, body: { id: 1 }.to_json, headers: {})
end

def stub_get_empty_matching_title
  response = []

  stub_request(:get, 'http://fake/contenido/buscar?Content-Type=application/json&titulo=Titanic')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_one_matching_title
  response = [{ 'id' => 1, 'titulo' => 'Akira', 'anio' => 1988, 'genero' => 'accion' }]

  stub_request(:get, 'http://fake/contenido/buscar?Content-Type=application/json&titulo=Akira')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
end

def stub_get_two_matching_titles
  response = [{ 'id' => 1, 'titulo' => 'Akira', 'anio' => 1988, 'genero' => 'accion' },
              { 'id' => 2, 'titulo' => 'Akira 2', 'anio' => 1990, 'genero' => 'accion' }]

  stub_request(:get, 'http://fake/contenido/buscar?Content-Type=application/json&titulo=Akira')
    .with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status: 200, body: response.to_json, headers: {})
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

  def stub_and_send_first_user(token)
    stub_post_request_usuario('emilio@gmail.com', 1_234_556, 201)
    when_i_send_text_with_id_telegram(token, '/registrar emilio@gmail.com', 1_234_556)
    then_i_get_text(token, 'Bienvenido, cinéfilo Emilio!')
  end

  def stub_and_send_second_user(token)
    message = 'El telegram ID ya está asociado con una cuenta existente.'
    field = :id_telegram
    stub_post_request_usuario_error('pablito@gmail.com', 1_234_556, 409, message, field)
    when_i_send_text_with_id_telegram(token, '/registrar pablito@gmail.com', 1_234_556)
    then_i_get_text(token, 'Error, tu usuario de telegram ya esta asociado a una cuenta existente')
  end

  def stub_and_send_third_user(token)
    message = 'El email ya está asociado con una cuenta existente.'
    field = :email
    stub_post_request_usuario_error('emilio@gmail.com', 987_654_3, 409, message, field)
    when_i_send_text_with_id_telegram(token, '/registrar emilio@gmail.com', 987_654_3)
    then_i_get_text(token, 'Error, el email ingresado ya esta asociado a una cuenta existente')
  end

  it 'debería recibir un mensaje /registrar con número de telegram repetido y responder con un mensaje de error' do
    token = 'fake_token'
    stub_and_send_first_user(token)
    stub_and_send_second_user(token)
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /registrar con un email ya registrado y responder con un error' do
    token = 'fake_token'
    stub_and_send_first_user(token)
    stub_and_send_third_user(token)
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /masvistos y devolver los contenidos más vistos de la plataforma' do
    token = 'fake_token'
    stub_get_top_visualizaciones
    when_i_send_text(token, '/masvistos')
    then_i_get_top_visualizaciones(token)
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /masvistos cuando no hay visualizaciones de películas y devolver un mensaje de la situación' do
    token = 'fake_token'
    stub_get_empty_top_visualizaciones
    when_i_send_text(token, '/masvistos')
    then_i_get_text(token, 'No hay datos de visualizaciones de películas en el momento')
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /calificar {id_pelicula} {calificacion} y devolver un mensaje' do
    token = 'fake_token'
    stub_post_request_calificacion(141_733_544, 97, 4, 201)
    when_i_send_text(token, '/calificar 97 4')
    then_i_get_text(token, 'Calificacion registrada exitosamente')
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /marcar_favorita {id_pelicula} y devolver un mensaje de contenido anadido a favoritos' do\
    token = 'fake_token'
    stub_post_request_marcar_favorita('test@test.com', 1, 201)
    when_i_send_text(token, '/marcar_favorita 1')
    then_i_get_text(token, 'Contenido añadido a favoritos')
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /buscartitulo {titulo} y devolver un mensaje con los resultados de la búsqueda cuando no hay coincidencias' do
    token = 'fake_token'
    stub_get_empty_matching_title
    when_i_send_text(token, '/buscartitulo Titanic')
    then_i_get_text(token, 'No se encontraron resultados para la búsqueda')
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /buscartitulo {titulo} y devolver un mensaje con los resultados de la búsqueda cuando hay una coincidencia' do
    token = 'fake_token'
    stub_get_one_matching_title
    when_i_send_text(token, '/buscartitulo Akira')
    result = "Acá están los titulos que coinciden con tu busqueda:\n- [ID: 1] Akira (accion, 1988)\n"
    then_i_get_text(token, result)
    BotClient.new(token).run_once
  end

  it 'debería recibir un mensaje /buscartitulo {titulo} y devolver un mensaje con los resultados de la búsqueda cuando hay varias coincidencias' do
    token = 'fake_token'
    stub_get_two_matching_titles
    when_i_send_text(token, '/buscartitulo Akira')
    result = "Acá están los titulos que coinciden con tu busqueda:\n- [ID: 1] Akira (accion, 1988)\n- [ID: 2] Akira 2 (accion, 1990)\n"
    then_i_get_text(token, result)
    BotClient.new(token).run_once
  end
end
