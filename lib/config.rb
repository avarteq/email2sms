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
      puts "\n\n-------------------------------------\n"
      puts "Didn't find a configuration file in #{config_file_path}. First start?"
      puts "I am going to create a configuration file template for you under #{config_file_path}."
      puts "Please adapt it to your needs and start the daemon again."
      puts "-------------------------------------\n\n"
      config_file = File.new(config_file_path, "w+")
      config_file.puts File.open(default_config_file_path).read
    end

    config = YAML.load_file(config_file_path)
    config 
  end
  
  def self.logdir
    mylogdir = ""
    
    config = self.load
    
    # If there is no configuration file, it will be generated but it wouldn't make 
    # sense to load it. The user has to customize it, first.
    if config    
      if config["log"]["dir_mode"] == "current" then
        mylogdir = Dir.pwd
      elsif config["log"]["dir_mode"] == "normal" then
        mylogdir = config["log"]["dir"]      
        exists_or_create_dir(mylogdir)
      else
        raise "Unknown log dir_mode #{config[:log][:dir_mode]}. Possible values are: 'current' and 'normal'."
      end  
    end
    mylogdir || Dir.pwd
  end
  
  protected
  
  # Checks whether the given dir exists. Creates it if not.
  def self.exists_or_create_dir(dir)  
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
  end
end