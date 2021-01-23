require 'telegram/bot'
require File.dirname(__FILE__) + '/../app/routes'

class BotClient
  def initialize(token = ENV['TELEGRAM_TOKEN'], log_level=ENV['LOG_LEVEL'])
    @token = token
    @logger = Logger.new(STDOUT)
    @logger.level = log_level.to_i
  end

  def start
    @logger.info "Starting bot version:#{Version.current}"
    @logger.info "token is #{@token}"
    run_client do |bot|
      begin
        bot.listen { |message| handle_message(message, bot) }
      rescue => e
        @logger.fatal e.message
      end
    end
  end

  def run_once
    run_client do |bot|
      bot.fetch_updates { |message| handle_message(message, bot) }
    end
  end

  private

  def run_client(&block)
    Telegram::Bot::Client.run(@token, logger: @logger) { |bot| block.call bot }
  end

  def handle_message(message, bot)
    @logger.debug "From: @#{message.from.username}, message: #{message.inspect}"

    Routes.new.handle(bot, message)
  end
end
