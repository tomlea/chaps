class LoggingIO
  def initialize(io)
    @io = io
  end
  
  def gets
    data = @io.gets
    STDOUT << "<< #{data}"
    data
  end
  
  def puts(data)
    self << data + "\n"
  end
  
  def <<(data)
    STDOUT << ">> #{data}"
    @io << data
  end
end
