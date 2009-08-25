class BasicFilter

  def initialize(charset = "UTF-8")
    @charset = charset
  end

  def passed_filter?(tmail)
    raise "unimplemented"
  end
end