require 'dotenv/load'
require_relative 'app/bot_client'

$stdout.sync = true
BotClient.new.start
