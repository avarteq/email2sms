class FilterChain

  def initialize
    @filters = []
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

  def self.build_simple_filter_chain
    filter_chain = self.new
    filter_chain << SubjectFilter.new()

    return filter_chain
  end
end