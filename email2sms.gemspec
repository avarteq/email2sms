# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{email2sms}
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julian Fischer"]
  s.date = %q{2009-08-28}
  s.default_executable = %q{email2smsd}
  s.description = %q{Free and pure Ruby E-Mail to sms gateway including an extensible filterchain to filter and manipulate incoming emails before sending them as text messages.}
  s.email = %q{email2sms@avarteq.de}
  s.executables = ["email2smsd"]
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    ".gitignore",
     "README.textile",
     "Rakefile",
     "VERSION",
     "bin/email2smsd",
     "config/email2sms.yml",
     "email2sms.gemspec",
     "lib/config.rb",
     "lib/email2sms_main.rb",
     "lib/email_to_sms.rb",
     "lib/filter/basic_filter.rb",
     "lib/filter/filter_chain.rb",
     "lib/filter/subject_filter.rb",
     "lib/mail/imap_tools.rb",
     "lib/mail/tmail_tools.rb"
  ]
  s.homepage = %q{http://github.com/avarteq/email2sms}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Pure Ruby e-mail to sms gateway}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<developergarden_sdk>, ["= 0.0.8"])
      s.add_runtime_dependency(%q<daemons>, ["= 1.0.10"])
      s.add_runtime_dependency(%q<tmail>, ["= 1.2.3.1"])
    else
      s.add_dependency(%q<developergarden_sdk>, ["= 0.0.8"])
      s.add_dependency(%q<daemons>, ["= 1.0.10"])
      s.add_dependency(%q<tmail>, ["= 1.2.3.1"])
    end
  else
    s.add_dependency(%q<developergarden_sdk>, ["= 0.0.8"])
    s.add_dependency(%q<daemons>, ["= 1.0.10"])
    s.add_dependency(%q<tmail>, ["= 1.2.3.1"])
  end
end
