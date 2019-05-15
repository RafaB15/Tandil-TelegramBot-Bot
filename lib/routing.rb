module Routing
  @message_handlers = {}

  DEFAULT = '_default_handler_'.freeze

  def self.message_handlers
    @message_handlers
  end

  def self.included(clazz)
    clazz.extend ClazzMethods
  end

  def handle(bot, message)
    handler = Routing.message_handlers[message.text] || default_handler(message.text)

    handler.call(bot, message)
  end

  def default_handler(message)
    Routing.message_handlers[DEFAULT] ||
      (raise "Unkown message [#{message}]. Please define new handler or a default handler")
  end

  module ClazzMethods
    def on(expected_message, &block)
      Routing.message_handlers[expected_message] = block
    end

    def default(&block)
      Routing.message_handlers[DEFAULT] = block
    end
  end
end
