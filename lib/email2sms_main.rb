#!/usr/bin/env ruby

require 'rubygems'
gem 'developergarden_sdk'
require 'sms_service/sms_service'
require 'quota_service/quota_service'
require 'tmail'

require File.dirname(__FILE__) + '/../lib/' + 'config.rb'
require File.dirname(__FILE__) + '/../lib/' + 'mail/tmail_tools'
require File.dirname(__FILE__) + '/../lib/' + 'mail/imap_tools'
require File.dirname(__FILE__) + '/../lib/' + 'email_to_sms'
require File.dirname(__FILE__) + '/../lib/' + 'filter/filter_chain'
require File.dirname(__FILE__) + '/../lib/' + 'filter/basic_filter'
require File.dirname(__FILE__) + '/../lib/' + 'filter/subject_filter'

# Catching the exit signal and 
Signal.trap(0, proc do
  puts "Stopping email2sms"
  email2sms.close
end
)

Net::IMAP.debug = true if $DEBUG

CONFIG = Config.load

puts "Creating email2sms main class"
email2sms = EmailToSms.new( EmailToSms.ENVIRONMENT_PRODUCTION )

puts "Entering dispatch loop"
loop do
  email2sms.dispatch
  sleep CONFIG["imap"]["poll_interval"]
end


