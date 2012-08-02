module Ratis

  Config = Struct.new :endpoint, :namespace, :proxy, :timeout do

    def valid?
      return true unless endpoint.blank? or namespace.blank?
      false
    end

  end
  
  extend self

  attr_writer :config

  def configure
    yield config
  end

  def config
    @config ||= Config.new
  end

end

