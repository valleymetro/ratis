module Ratis

  class Config

    attr_accessor :endpoint, :namespace, :proxy, :timeout

    def valid?
      return false if endpoint.nil? or namespace.nil?
      return false if endpoint.empty? or namespace.empty?
      true
    end

  private

    def initialize
      @timeout = 5
    end

  end

end
