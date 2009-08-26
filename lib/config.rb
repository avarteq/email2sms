module Config
  def self.load
    config_filename = "email2sms.yml"
    default_config  = YAML.load_file(File.dirname(__FILE__) + "/../config/" + config_filename)
    default_config_file_path = File.dirname(__FILE__) + "/../config/email2sms.yml"

    config_dir        = ENV["HOME"] + "/.email2sms"
    config_file_path  = config_dir + "/" + config_filename

    # Check or create config dir
    unless File.directory?(config_dir) then
      FileUtils.mkdir(config_dir)  
    end

    # Check or create config file
    unless File.exists?(config_file_path) then
      config_file = File.new(config_file_path, "w+")
      config_file.puts File.open(default_config_file_path).read
    end

    config = YAML.load_file(config_file_path)
    config  
  end
end