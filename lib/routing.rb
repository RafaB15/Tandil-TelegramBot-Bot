module Routing
  @message_handlers = {}
  @callback_query_handlers = {}

  DEFAULT = '_default_handler_'.freeze

  def self.message_handlers
    @message_handlers
  end

  def self.callback_query_handlers
    @callback_query_handlers
  end

  def self.included(clazz)
    clazz.extend ClazzMethods
  end

  def handle(bot, message)
    handler = find_handler_for(message) || default_handler(message)

    handler.call(bot, message)
  end

  module ClazzMethods
    def on_message(expected_message, &block)
      Routing.message_handlers[expected_message] = block
    end

    def on_response_to(expected_message, &block)
      Routing.callback_query_handlers[expected_message] = block
    end

    def default(&block)
      Routing.message_handlers[DEFAULT] = block
    end
  end

  private

  def find_handler_for(message)
    case message
    when Telegram::Bot::Types::Message
      Routing.message_handlers[message.text]
    when Telegram::Bot::Types::CallbackQuery
      Routing.callback_query_handlers[message.message.text]
    end
  end

  def default_handler(message)
    Routing.message_handlers[DEFAULT] ||
      (raise "Unkown message [#{message.inspect}]. Please define new handler or a default handler")
  end
end
