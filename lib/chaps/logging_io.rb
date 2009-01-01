class LoggingIO
  def initialize(io, enabled = false)
    @io, @enabled = io, enabled
  end
  
  def gets
    data = @io.gets
    STDOUT << "<< #{data}" if @enabled
    data
  end
  
  def puts(data)
    self << data + "\n"
  end
  
  def <<(data)
    STDOUT << ">> #{data}"  if @enabled
    @io << data
  end
end
