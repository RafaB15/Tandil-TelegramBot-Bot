require 'telegram/bot'
require File.dirname(__FILE__) + '/../app/routes'
require 'semantic_logger'

class BotClient
  def initialize(token = ENV['TELEGRAM_TOKEN'], log_level = ENV['LOG_LEVEL'] || 'error', log_url = ENV['LOG_URL'] || 'http://fake.url')
    @token = token
    SemanticLogger.default_level = log_level.to_sym
    SemanticLogger.add_appender(
      io: $stdout
    )
    SemanticLogger.add_appender(
      appender: :http,
      url: log_url
    )
    @logger = SemanticLogger['BotClient']
  end

  def start
    @logger.info "Starting bot version:#{Version.current}"
    @logger.info "token is #{@token}"
    run_client do |bot|
      bot.listen { |message| handle_message(message, bot) }
    rescue StandardError => e
      @logger.fatal e.message
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
