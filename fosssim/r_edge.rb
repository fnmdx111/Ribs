require_relative 'countable'

class REdge
  attr_reader :end_points, :radius, :color

  include Identifiable

  def initialize end_points, radius=1, color=:random
    @end_points = end_points
    @radius = radius
    @color = color
  end
end
