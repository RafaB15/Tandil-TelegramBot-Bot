require 'spec_helper'
require 'web_mock'
# Uncomment to use VCR
# require 'vcr_helper'

require File.dirname(__FILE__) + '/../app/bot_client'

def stub_get_updates(token, message_text)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def stub_send_message(token, message_text)
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

def stub_send_keyboard_message(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544',
              'reply_markup' => '{"inline_keyboard":[[{"text":"Jon Snow","callback_data":"1"}],[{"text":"Daenerys Targaryen","callback_data":"2"}],[{"text":"Ned Stark","callback_data":"3"}]]}',
              'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

describe 'BotClient' do
  it 'should get a /say_hi message and respond with Hola Emilio' do
    token = 'fake_token'

    stub_get_updates(token, '/say_hi Emilio')
    stub_send_message(token, 'Hola, Emilio')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a /start message and respond with Hola' do
    token = 'fake_token'

    stub_get_updates(token, '/start')
    stub_send_message(token, 'Hola, Emilio')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a /stop message and respond with Chau' do
    token = 'fake_token'

    stub_get_updates(token, '/stop')
    stub_send_message(token, 'Chau, egutter')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get a /tv message and respond with an inline keyboard' do
    token = 'fake_token'

    stub_get_updates(token, '/tv')
    stub_send_keyboard_message(token, 'Quien se queda con el trono?')

    app = BotClient.new(token)

    app.run_once
  end

  it 'should get an unknown message message and respond with Do not understand' do
    token = 'fake_token'

    stub_get_updates(token, '/unknown')
    stub_send_message(token, 'Uh? No te entiendo! Me repetis la pregunta?')

    app = BotClient.new(token)

    app.run_once
  end
end
