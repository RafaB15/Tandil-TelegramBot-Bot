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

def when_i_send_text_with_telegram_id(token, message_text, telegram_id)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": telegram_id, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

# def when_i_send_keyboard_updates(token, message_text, inline_selection)
#   body = {
#     "ok": true, "result": [{
#       "update_id": 866_033_907,
#       "callback_query": { "id": '608740940475689651', "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
#                           "message": {
#                             "message_id": 626,
#                             "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
#                             "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
#                             "date": 1_595_282_006,
#                             "text": message_text,
#                             "reply_markup": {
#                               "inline_keyboard": [
#                                 [{ "text": 'Jon Snow', "callback_data": '1' }],
#                                 [{ "text": 'Daenerys Targaryen', "callback_data": '2' }],
#                                 [{ "text": 'Ned Stark', "callback_data": '3' }]
#                               ]
#                             }
#                           },
#                           "chat_instance": '2671782303129352872',
#                           "data": inline_selection }
#     }]
#   }
#
#   stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
#     .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
# end

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

# def then_i_get_keyboard_message(token, message_text)
#   body = { "ok": true,
#            "result": { "message_id": 12,
#                        "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
#                        "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
#                        "date": 1_557_782_999, "text": message_text } }
#
#   stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
#     .with(
#       body: { 'chat_id' => '141733544',
#               'reply_markup' => '{"inline_keyboard":[[{"text":"Jon Snow","callback_data":"1"},{"text":"Daenerys Targaryen","callback_data":"2"},{"text":"Ned Stark","callback_data":"3"}]]}',
#               'text' => 'Quien se queda con el trono?' }
#     )
#     .to_return(status: 200, body: body.to_json, headers: {})
# end

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

def stub_post_request_usuario(email, telegram_id, status)
  response = { id: 1, email:, telegram_id: }
  stub_request(:post, 'http://fake/usuarios')
    .with(
      body: "{\"email\":\"#{email}\",\"telegram_id\":#{telegram_id}}",
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v2.7.4'
      }
    )
    .to_return(status:, body: response.to_json, headers: {})
end

def stub_post_request_usuario_error(email, telegram_id, status, message, field)
  response = {  error: 'Conflicto',
                message:,
                field: }
  stub_request(:post, 'http://fake/usuarios')
    .with(
      body: "{\"email\":\"#{email}\",\"telegram_id\":#{telegram_id}}",
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
  response = [
    {
      "titulo": 'Iron Man',
      "id": 1
    },
    {
      "titulo": 'Black Panther',
      "id": 2
    },
    {
      "titulo": 'Doctor Strange',
      "id": 3
    }
  ]

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
  text = "Las películas con más visualizaciones son:\n  1. Iron Man (1)\n  2. Black Panther (2)\n  3. Doctor Strange (3)\n"
  then_i_get_text(token, text)
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
    when_i_send_text_with_telegram_id(token, '/registrar emilio@gmail.com', 1_234_556)
    then_i_get_text(token, 'Bienvenido, cinéfilo Emilio!')
  end

  def stub_and_send_second_user(token)
    message = 'El telegram ID ya está asociado con una cuenta existente.'
    field = :telegram_id
    stub_post_request_usuario_error('pablito@gmail.com', 1_234_556, 409, message, field)
    when_i_send_text_with_telegram_id(token, '/registrar pablito@gmail.com', 1_234_556)
    then_i_get_text(token, 'Error, tu usuario de telegram ya esta asociado a una cuenta existente')
  end

  def stub_and_send_third_user(token)
    message = 'El email ya está asociado con una cuenta existente.'
    field = :email
    stub_post_request_usuario_error('emilio@gmail.com', 987_654_3, 409, message, field)
    when_i_send_text_with_telegram_id(token, '/registrar emilio@gmail.com', 987_654_3)
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
end
