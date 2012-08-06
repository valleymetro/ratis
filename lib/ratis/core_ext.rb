Hash.class_eval do

  # Traverses the Hash for a given +path+ of Hash keys and returns
  # the value as an Array. Defaults to return an empty Array in case the path does not
  # exist or returns nil.
  # Copied from Savon::SOAP::Response#to_array
  def to_array(*path)
    result = path.inject self do |memo, key|
      return [] unless memo[key]
      memo[key]
    end

    [result].compact.flatten(1)
  end

end

class TrueClass
  def y_or_n
    'y'
  end
end

class FalseClass
  def y_or_n
    'n'
  end
end

class String
  def y_or_n
    raise ArgumentError.new 'Expecting y or n' unless ['y', 'n'].include? self.downcase
    self
  end
end
