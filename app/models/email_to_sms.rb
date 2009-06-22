require 'net/imap'
require File.dirname(__FILE__) + '/imap/imap_tools'


class EmailToSms

  include Imap::ImapTools

  @@RECEIVER = "0177-3383539"
  @@SENT_SMS_MAILBOX = "sent_sms"
  @@FILTERED_MAILBOX = "filtered"

  @@ENVIRONMENT_MOCK = 2
  @@ENVIRONMENT_PRODUCTION = 1
  
  @@CHARSET = "UTF-8"

  def initialize(environment = @@ENVIRONMENT_MOCK)

    @environment = environment
    @filter_chain = FilterChain.build_simple_filter_chain(@@CHARSET)
    @sms_service = SmsService::SmsService.new("bjuler222@t-online.de", "Sho3eig5")

    @imap = Net::IMAP.new('mail.railshoster.de')
    @imap.authenticate('LOGIN', 'sms2email@railshoster.de', 'The2Ieto')

    @decoder = QuotedPrintable.new

    status_or_create_send_sms_mailbox
    status_or_create_filtered_mailbox
  end

  # See which emails to send
  def dispatch

    @imap.select('INBOX')

    puts "Starting to process emails..."
    @imap.uid_search(["UNSEEN"]).each do |uid|

      # Get the email in rfc822 format
      mail_rfc822 = @imap.uid_fetch(uid, 'RFC822')[0].attr['RFC822']

      # A TMail object hides all the quoting and parsing stuff
      tmail = TMail::Mail.parse( mail_rfc822 )

      # Only mails passing all filters will be delivered.
      # Be aware that filters might modify the mail.
      passed = @filter_chain.passed_filter?(tmail)

      if not passed then
        puts "E-mail wurde ausgefiltert."

        # Move email to the filtered mailbox
        move_email(uid, @@FILTERED_MAILBOX)
      else
        puts "E-mail wird versendet."

        send_email_as_sms(uid, tmail)
      end

    end
  end

  # Close imap connection
  def close
    @imap.close
    @imap.disconnect
  end

  protected

  #### non public methods

  # A mailbox is an imap folder.
  def status_or_create_send_sms_mailbox
    status_or_create_mailbox(@@SENT_SMS_MAILBOX)
  end

  # A mailbox is an imap folder.
  def status_or_create_filtered_mailbox
    status_or_create_mailbox(@@FILTERED_MAILBOX)
  end

  def send_email_as_sms(uid, tmail)

    final_sms_message = tmail_to_plaintext(tmail)

    receiver = get_receiver_from_subject(tmail)

    if @environment == @@ENVIRONMENT_PRODUCTION then

      @sms_service.send_sms(receiver, final_sms_message, "Email2Sms", ServiceEnvironment.PRODUCTION)
      puts "Text message has ben sent."
    else

      puts "\n\n-----------------------"
      puts "E-Mail message:"
      puts tmail.subject
      puts tmail_to_plaintext(tmail)
      puts "-----------------------\n\n"

      # MOCK environment so we don't send any sms just print it out
      puts "\n\n-----------------------"
      puts "Text message to #{receiver}:"
      puts final_sms_message
      puts "-----------------------\n\n"
    end

    # Copy mail to sent_sms folder
    move_email(uid, @@SENT_SMS_MAILBOX)
  end

  # Extracts the receiver's number from the email subject
  def get_receiver_from_subject(tmail)
    return tmail.subject(@@CHARSET).strip    
  end

  # If it is a multipart email with a plain text part
  # it searches for the text/plain part of the mail and returns it.
  def tmail_to_plaintext(tmail)
    if tmail.multipart?
      tmail.parts.each do |part|
        return part.body(@@CHARSET) if part.content_type == 'text/plain'
      end
    else
      return tmail.body(@@CHARSET)
    end
  end


  #### Public static methods


  def self.ENVIRONMENT_MOCK
    return @@ENVIRONMENT_MOCK
  end

  def self.ENVIRONMENT_PRODUCTION
    return @@ENVIRONMENT_PRODUCTION
  end
end


