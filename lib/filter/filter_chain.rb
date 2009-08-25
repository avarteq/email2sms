# The filter chain is responsible for deciding which mail to forward and which to drop.
# The filter chain can consist of one ore more filters each analysing and/or modifing the incoming
# mail.
class FilterChain
  
  def initialize(config)
    @filters = []
    @config = config
  end

  def <<(filter)
    @filters << filter   
  end

  def add(filter)
    @filters << filter
  end

  def delete(filter)
    @filters.delete(filter)
  end

  # Execute each filter, stop of a filter rejects the mail
  def passed_filter?(tmail)
    ret = true
    for filter in @filters do
      if not filter.passed_filter?(tmail) then
        ret = false
        break
      end
    end
    return ret
  end

  # Factory method to create a simple filter chaing using a SubjectFilter.
  def self.build_simple_filter_chain(config, charset = "UTF-8")
    filter_chain            = self.new(config)    
    subject_filter_password = config["filter_chain"]["subject_filter"]["password"]
    filter_chain << SubjectFilter.new(subject_filter_password, charset)
    return filter_chain
  end
end