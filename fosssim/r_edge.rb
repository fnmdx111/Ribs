require_relative 'countable'

class REdge
  attr_reader :end_points, :radius, :color, :par_x, :par_y

  include Identifiable

  def initialize scene, end_points, radius=15, color=:random
    @end_points = end_points
    @radius = radius
    @color = if color == :random
               [rand, rand, rand]
             else
               color
             end

    @start = scene.particles.index {|p| p.id == end_points[0]}
    @end = scene.particles.index {|p| p.id == end_points[1]}
    @par_x = scene.particles[@start]
    @par_x.edges.push self
    @par_y = scene.particles[@end]
    @par_y.edges.push self

    @scene = scene
    @edge_img = TexPlay.create_blank_image scene.window, *scene.size
  end

  def draw
    unless @par_x.locked? and @par_y.locked?
      @edge_img.clear

      @edge_img.line @par_x.pos.px, @par_x.pos.py, @par_y.pos.px, @par_y.pos.py,
                     :color => @color, :thickness => @radius * 2
    end
    @edge_img.draw 0, 0, ZOrder::LINES
  end
end
