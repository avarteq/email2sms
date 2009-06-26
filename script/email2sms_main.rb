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

Net::IMAP.debug = true if $DEBUG

CONFIG = YAML.load_file(File.dirname(__FILE__) + "/../config/email2sms.yml")

email2sms = EmailToSms.new( EmailToSms.ENVIRONMENT_PRODUCTION )

loop do
  email2sms.dispatch
  sleep CONFIG["imap"]["poll_interval"]
end

email2sms.close

