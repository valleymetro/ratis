module Ratis

  Config = Struct.new :endpoint, :namespace, :proxy, :timeout 
  
  extend self

  def configure
    yield config
  end

  def config
    @config ||= Config.new
  end

  attr_writer :config

end

