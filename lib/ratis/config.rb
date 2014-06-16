module Ratis

  class Config

    attr_accessor :appid, :endpoint, :log, :log_level, :namespace, :proxy, :timeout

    def valid?
      !(endpoint.nil? || endpoint.empty? || namespace.nil? || namespace.empty? || appid.nil? || appid.empty?)
    end

  private

    def initialize
      @timeout = 5
    end

  end

end
