# IMAP related methods
module Mail
  module ImapTools
  
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
        # Mailbox already exists
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
  end
end