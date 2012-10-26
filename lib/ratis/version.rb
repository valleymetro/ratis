module Ratis

  extend self

  def version
    @version ||= begin
      string = '2.5.2.3'

      def string.parts
        split('.').map { |p| p.to_i }
      end

      def string.major
        parts[0]
      end

      def string.minor
        parts[1]
      end

      def string.build
        parts[2]
      end

      def string.patch
        parts[3]
      end

      string
    end
  end

end
