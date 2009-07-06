#!/usr/bin/env ruby

# Load Rails environment
#require File.join(File.dirname(__FILE__),"..","config", "environment")


require 'rubygems'
gem 'telekom_sdk'
require 'sms_service/sms_service'
require 'voice_call_service/voice_call_service'
require 'quota_service/quota_service'
require 'tmail'

require File.dirname(__FILE__) + '/../app/models/' + 'email_to_sms'
require File.dirname(__FILE__) + '/../app/models/' + 'filter_chain'
require File.dirname(__FILE__) + '/../app/models/' + 'basic_filter'
require File.dirname(__FILE__) + '/../app/models/' + 'subject_filter'

# Catching the exit signal and 
Signal.trap(0, proc do
  puts "Stopping email2sms"
  email2sms.close
end
)

Net::IMAP.debug = true if $DEBUG

puts "Loading email2sms config file"
CONFIG = YAML.load_file(File.dirname(__FILE__) + "/../config/email2sms.yml")

puts "Creating email2sms main class"
#email2sms = EmailToSms.new( EmailToSms.ENVIRONMENT_PRODUCTION )

puts "Entering dispatch loop"
loop do
#  email2sms.dispatch
  puts "."
  sleep CONFIG["imap"]["poll_interval"]
end



