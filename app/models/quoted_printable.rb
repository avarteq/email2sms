# Source code taken from actionmailer-1.3.5/lib/action_mailer/vendor/tmail/quoting.rb
class QuotedPrintable

  # For strings like "=?ISO-8859-1?Q?Aihie4ca6a_=FCber_=E4ndern_=F6sterreich?=" 
  def unquote_and_convert_to(text, to_charset, from_charset = "iso-8859-1", preserve_underscores=false)
    return "" if text.nil?
    text.gsub(/(.*?)(?:(?:=\?(.*?)\?(.)\?(.*?)\?=)|$)/) do
      before = $1
      from_charset = $2
      quoting_method = $3
      text = $4

      before = convert_to(before, to_charset, from_charset) if before.length > 0
      before +
              case quoting_method
                when "q", "Q" then
                  unquote_quoted_printable_and_convert_to(text, to_charset, from_charset, preserve_underscores)
                when "b", "B" then
                  unquote_base64_and_convert_to(text, to_charset, from_charset)
                when nil then
                  # will be nil at the end of the string, due to the nature of
                  # the regex used.
                  ""
                else
                  raise "unknown quoting method #{quoting_method.inspect}"
              end
    end
  end

  # For strings like "=FCber_=E4ndern_=F6sterreich"
  def unquote_quoted_printable_and_convert_to(text, to, from, preserve_underscores=false)
    text = text.gsub(/_/, " ") unless preserve_underscores
    text = text.gsub(/\r\n|\r/, "\n") # normalize newlines
    convert_to(text.unpack("M*").first, to, from)
  end

  def unquote_base64_and_convert_to(text, to, from)
    convert_to(Base64.decode(text).first, to, from)
  end

  begin
    require 'iconv'

    def convert_to(text, to, from)
      return text unless to && from
      text ? Iconv.iconv(to, from, text).first : ""
    rescue Iconv::IllegalSequence, Iconv::InvalidEncoding, Errno::EINVAL
      # the 'from' parameter specifies a charset other than what the text
      # actually is...not much we can do in this case but just return the
      # unconverted text.
      #
      # Ditto if either parameter represents an unknown charset, like
      # X-UNKNOWN.
      text
    end
  rescue LoadError
    # Not providing quoting support
    def convert_to(text, to, from)
      warn "Action Mailer: iconv not loaded; ignoring conversion from #{from} to #{to} (#{__FILE__}:#{__LINE__})"
      text
    end
  end
end