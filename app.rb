require 'dotenv/load'
require File.dirname(__FILE__) + '/app/bot_client'

BotClient.new.start
