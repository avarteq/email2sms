#!/usr/bin/env ruby
#require File.dirname(__FILE__) + '/../config/boot'
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
require File.dirname(__FILE__) + '/../app/models/' + 'quoted_printable'


Net::IMAP.debug = true

email2sms = EmailToSms.new( EmailToSms.ENVIRONMENT_PRODUCTION )

#while(true) do
  email2sms.dispatch
#  sleep 2
#end

email2sms.close

