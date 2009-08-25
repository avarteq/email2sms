require 'net/imap'

class EmailToSms

  include Mail::ImapTools
  include Mail::TmailTools

  @@SENT_SMS_MAILBOX        = "sent_sms"
  @@ERROR_SMS_MAILBOX       = "error"  
  @@FILTERED_MAILBOX        = "filtered"
  @@ENVIRONMENT_MOCK        = 2
  @@ENVIRONMENT_PRODUCTION  = 1
  @@CONFIG = YAML.load_file(File.dirname(__FILE__) + "/../config/email2sms.yml")

  def initialize(environment = @@ENVIRONMENT_MOCK)
    @charset        = @@CONFIG["general"]["default_charset"]
    @environment    = environment
    @filter_chain   = FilterChain.build_simple_filter_chain(@@CONFIG, @charset)
    dev_garden_user = @@CONFIG["dev_garden"]["user"]
    dev_garden_pass = @@CONFIG["dev_garden"]["pass"]
    @sms_service    = SmsService::SmsService.new(dev_garden_user, dev_garden_pass)
    @imap           = Net::IMAP.new(@@CONFIG["imap"]["server_host"])
    imap_user       = @@CONFIG["imap"]["user"]
    imap_pass       = @@CONFIG["imap"]["pass"]
    @imap.authenticate('LOGIN', imap_user, imap_pass)
    status_or_create_mailboxes
  end

  # See which emails to send
  def dispatch
    @imap.select('INBOX')
    puts "Checking mailbox..."
    @imap.uid_search(["UNSEEN"]).each do |uid_unseen|
      tmail_unseen = tmail_from_imap(uid_unseen)

      # Only mails passing all filters will be delivered.
      # Be aware that filters might modify the mail.
      passed = @filter_chain.passed_filter?(tmail_unseen)

      if not passed then
        puts "E-mail has been filtered."
        move_email(uid_unseen, @@FILTERED_MAILBOX)
      else        
        puts "Sending E-mail as text message..."
        send_email_as_sms(uid_unseen, tmail_unseen)
      end
    end
  end

  # Close imap connection
  def close
    @imap.close
    @imap.disconnect
  end
 
  protected

  def tmail_from_imap(uid)
    # Get the email in rfc822 format
    mail_rfc822 = @imap.uid_fetch(uid, 'RFC822')[0].attr['RFC822']

    # A TMail object hides all the quoting and parsing stuff
    tmail = TMail::Mail.parse( mail_rfc822 )    
    tmail
  end

  # Created needed imap folders
  def status_or_create_mailboxes
    [@@SENT_SMS_MAILBOX, @@FILTERED_MAILBOX, @@ERROR_SMS_MAILBOX].each do |mailbox|
      status_or_create_mailbox(mailbox)
    end
  end

  def send_email_as_sms(uid, tmail)                
    final_sms_message   = sms_message_from(tmail)
    receiver            = get_receiver_from_subject(tmail)
    sms_sender_name     = @@CONFIG["sms"]["sender_name"]

    if @environment == @@ENVIRONMENT_PRODUCTION then            
      send_email_as_sms_production(uid, receiver, final_sms_message, sms_sender_name)
    else
      send_email_as_sms_mock(uid, tmail, receiver, final_sms_message)
    end
  end
  
  def send_email_as_sms_production(uid, receiver, final_sms_message, sms_sender_name)
    rescue_send_sms_exceptions(uid) do |uid|
      @sms_service.send_sms(receiver, final_sms_message, sms_sender_name, ServiceEnvironment.PRODUCTION)
      puts "Text message has ben sent."
      
      # Copy mail to sent_sms folder
      move_email(uid, @@SENT_SMS_MAILBOX)            
    end
  end
  
  def send_email_as_sms_mock(uid, tmail, receiver, final_sms_message)
    
    # MOCK environment so we don't send any sms just print it out
    puts_tmail(tmail)
    puts_sms(receiver, final_sms_message)                    
    
    # Copy mail to sent_sms folder
    move_email(uid, @@SENT_SMS_MAILBOX)
  end
  
  def rescue_send_sms_exceptions(uid, &block)
    begin
      yield(uid)
    rescue ServiceException => e
      r = e.response
      puts "\tError while sending sms.\n\t\tError message: #{r.error_message}\n\t\tError code: #{r.error_code}"
      
      # Copy mail to sent_sms folder
      move_email(uid, @@ERROR_SMS_MAILBOX)
    end
  end
  
  def sms_message_from(tmail)
    final_sms_message = tmail_to_plaintext(tmail)

    # Shorten message
    final_sms_message = final_sms_message.strip![0, 150]
    final_sms_message
  end
  
  # Print the given sms message to stdout
  def puts_sms(receiver, final_sms_message)            
    puts "\n\n-----------------------"
    puts "Text message to #{receiver}:"
    puts final_sms_message
    puts "-----------------------\n\n"    
  end

  #### Public static methods

  def self.ENVIRONMENT_MOCK
    return @@ENVIRONMENT_MOCK
  end

  def self.ENVIRONMENT_PRODUCTION
    return @@ENVIRONMENT_PRODUCTION
  end
end
