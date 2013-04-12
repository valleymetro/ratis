module Ratis

  class Point2Point::RoutesOnlyResponse

    VALID_ATTRS = [:route, :direction, :service_type, :signage, :route_type]
    VALID_ATTRS.each { |attr| attr_accessor attr }

    def initialize(attrs = {})
      VALID_ATTRS.each do |attr|
        instance_variable_set "@#{attr.to_s}", (attrs[attr] || attrs[attr.to_s])
      end
    end

  end

end
