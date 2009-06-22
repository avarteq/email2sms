# Checks the subject of the incomming message for a specific password and rejects the mail if the
# passwort is not present.
class SubjectFilter < BasicFilter

  def initialize(password, charset = "UTF-8")
    super(charset)
    @password = password
  end

  # Returns true if password is present.
  # Password will be removed from the subject.
  def passed_filter?(tmail)
    password_is_present = !tmail.subject.match(@password).nil?

    password_matcher = Regexp.new("#{@password}\s+")
    
    if password_is_present then
      # Remove password from the subject
      tmail.subject = tmail.subject(@charset).gsub(password_matcher, "")
    end
    
    return password_is_present
  end
end