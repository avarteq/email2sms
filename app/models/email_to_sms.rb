require 'net/imap'


class EmailToSms

  @@RECEIVER = "0177-3383539"
  @@SENT_SMS_MAILBOX = "sent_sms"
  @@FILTERED_MAILBOX = "filtered"

  @@ENVIRONMENT_MOCK = 2
  @@ENVIRONMENT_PRODUCTION = 1

  @@FROM_ENCODING   = "ISO-8859-1"
  @@TARGET_ENCODING = "MacRoman"

  def initialize(environment = @@ENVIRONMENT_MOCK)

    @environment = environment
    @filter_chain = FilterChain.build_simple_filter_chain(@@TARGET_ENCODING)
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

  def send_email_as_sms(uid, tmail)

    final_sms_message = tmail_to_plaintext(tmail)

    if @environment == @@ENVIRONMENT_PRODUCTION then

      @sms_service.send_sms(@@RECEIVER, final_sms_message, "Email2Sms", ServiceEnvironment.PRODUCTION)
    else

      puts "\n\n-----------------------"
      puts "E-Mail message:"
      puts tmail.subject
      puts tmail_to_plaintext(tmail)
      puts "-----------------------\n\n"

      # MOCK environment so we don't send any sms just print it out
      puts "\n\n-----------------------"
      puts "Text message:"
      puts final_sms_message
      puts "-----------------------\n\n"
    end

    # Copy mail to sent_sms folder
    move_email(uid, @@SENT_SMS_MAILBOX)
  end

  # If it is a multipart email with a plain text part
  # it searches for the text/plain part of the mail and returns it.
  def tmail_to_plaintext(tmail)
    if tmail.multipart?
      tmail.parts.each do |part|
        return part.body(@@TARGET_ENCODING) if part.content_type == 'text/plain'
      end
    else
      return tmail.body(@@TARGET_ENCODING)
    end
  end

  #### IMAP operations

  # Deletes the email with the given uid
  def delete_email(uid)
    @imap.uid_store(uid, "+FLAGS", [:Deleted])
    @imap.expunge
  end

  # Move a mail from the current to the given mailbox.
  def move_email(uid, mailbox)

    # Copy mail to sent_sms folder
    @imap.uid_copy(uid, mailbox)
    delete_email(uid)
  end

  # A mailbox is an imap folder.
  def status_or_create_send_sms_mailbox
    status_or_create_mailbox(@@SENT_SMS_MAILBOX)
  end

  # A mailbox is an imap folder.
  def status_or_create_filtered_mailbox
    status_or_create_mailbox(@@FILTERED_MAILBOX)
  end

  # Checks whether the given mailbox exists and creates it if not.
  # If it exists it will be selected.
  #TODO check imap protocoll if there isn't a better way to do this.
  # === Parameters
  # <tt>mailbox</tt>:: Name of the mailbox (imap folder)
  # <tt>raise_on_select</tt>:: Raise an exception if a select is not possible. This also skips creation of the mailbox. Used for internal purposes.
  def status_or_create_mailbox(mailbox, raise_on_select = false)
    ret = nil

    begin

      ret = @imap.status(mailbox, ["MESSAGES", "RECENT", "UNSEEN"])

      # Mailbox already exist
    rescue Net::IMAP::NoResponseError => e

      # The mailbox does not exist (or is non-selectable for some reason)
      unless raise_on_select

        # So we create it
        @imap.create(mailbox)

        puts "Created mailbox #{mailbox}."

        # And select it
        status_or_create_mailbox(mailbox, true)
      else
        # For some reasons the creation/selection of the mailbox failed.
        # In order to avoid an infinte loop we give up after trying to create and select the mailbox once.
        raise e
      end
    end

    return ret
  end


  #### Public static methods


  def self.ENVIRONMENT_MOCK
    return @@ENVIRONMENT_MOCK
  end

  def self.ENVIRONMENT_PRODUCTION
    return @@ENVIRONMENT_PRODUCTION
  end
end


