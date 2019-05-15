require File.dirname(__FILE__) + '/../lib/routing'

class Routes
  include Routing

  on '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
  end

  on '/stop' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Goodbye, #{message.from.first_name}")
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Uh? I don't understand")
  end
end
