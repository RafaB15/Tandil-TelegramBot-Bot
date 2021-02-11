require 'dotenv/load'
require File.dirname(__FILE__) + '/app/bot_client'

$stdout.sync = true
BotClient.new.start
