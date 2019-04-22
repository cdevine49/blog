class LikeJSON
  def initialize(hash)
    @hash = hash
  end

  def writing(meth, value)
    return false unless meth.to_s[-1] == '='
    meth = meth[0...-1]
    if @hash.has_key?(meth.to_s)
      @hash[meth.to_s] = value
    elsif @hash.has_key?(meth.to_sym)
      @hash[meth.to_sym] = value
    else
      raise NoMethodError, 'undefined method #{meth} for #{self}'
    end
  end

  def method_missing(meth, *args, &block)
    if @hash.has_key?(meth.to_s)
      @hash[meth.to_s]
    elsif @hash.has_key?(meth.to_sym)
      @hash[meth.to_sym]
    elsif writing(meth, args[0])
      args[0]
    else
      raise NoMethodError, 'undefined method #{meth} for #{self}'
    end
  end
end