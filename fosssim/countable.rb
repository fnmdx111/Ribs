module Countable
  def count
    @counter ||= 0
    @counter += 1
  end
end

module Identifiable
  def self.included cls
    cls.extend Countable
  end

  attr_accessor :id
  def initialize
    @id = self.class.count
  end

  def hash
    @id
  end
end
