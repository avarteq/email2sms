module Mail
  module TmailTools
    
    # Prints the given tmail object to stdout
    def puts_tmail(tmail)
      puts "\n\n-----------------------"
      puts "E-Mail message:"
      puts tmail.subject
      puts tmail_to_plaintext(tmail)
      puts "-----------------------\n\n"
    end
    
    # Extracts the receiver's number from the email subject
    def get_receiver_from_subject(tmail)
      return tmail.subject(@charset).strip
    end
    
    # If it is a multipart email with a plain text part
    # it searches for the text/plain part of the mail and returns it.
    def tmail_to_plaintext(tmail)
      ret = nil    
      if tmail.multipart? then
        plain_text_body_from_multipart(tmail)
      else
        ret = tmail.body(@charset)
      end
      ret
    end

    # Extraxt the plain text body from a multipart email
    def plain_text_body_from_multipart(tmail)
      ret = nil    
      tmail.parts.each do |part|
        ret = part.body(@charset) if part.content_type == 'text/plain'
        break
      end
      ret
    end
  end
end