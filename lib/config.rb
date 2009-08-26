module Config
  def self.load
    config_filename = "email2sms.yml"
    default_config  = YAML.load_file(File.dirname(__FILE__) + "/../config/" + config_filename)
    default_config_file_path = File.dirname(__FILE__) + "/../config/email2sms.yml"

    config_dir        = ENV["HOME"] + "/.email2sms"
    config_file_path  = config_dir + "/" + config_filename

    # Check or create config dir
    exists_or_create_dir(config_dir)
    
    # Check or create config file
    unless File.exists?(config_file_path) then
      config_file = File.new(config_file_path, "w+")
      config_file.puts File.open(default_config_file_path).read
    end

    config = YAML.load_file(config_file_path)
    config  
  end
  
  def self.logdir
    mylogdir = ""
    config = self.load
        
    if config["log"]["dir_mode"] == "current" then
      mylogdir = Dir.pwd
    elsif config["log"]["dir_mode"] == "normal" then
      mylogdir = config["log"]["dir"]      
      exists_or_create_dir(mylogdir)
    else
      raise "Unknown log dir_mode #{config[:log][:dir_mode]}. Possible values are: 'current' and 'normal'."
    end  
    mylogdir
  end
  
  protected
  
  # Checks whether the given dir exists. Creates it if not.
  def self.exists_or_create_dir(dir)  
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
  end
end