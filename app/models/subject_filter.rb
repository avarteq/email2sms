# Checks the subject of the incomming message for a specific password and rejects the mail if the
# passwort is not present.
class SubjectFilter < BasicFilter

  PASSWORD = "Aihie4ca6a"

  # Returns true if password is present
  def passed_filter?(envelope)
    return !envelope.subject.match(PASSWORD).nil?
  end
end