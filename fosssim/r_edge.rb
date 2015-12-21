require_relative 'countable'

class REdge
  attr_accessor :radius, :color, :start, :end
  attr_reader :par_x, :par_y

  include Identifiable

  def hash_dump
    {:id => @id, :radius => @radius, :color => @color,
     :start => @end_points[0], :end => @end_points[1]}
  end

  def initialize scene, end_points, radius=15, color=:random
    super()

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

  def start= v
    unless @par_x.nil?
      @par_x.edges.delete {|x| x.id == @id}
    end

    @start = @scene.particles.index {|p| p.id == v}
    @par_x = @scene.particles[@start]
    @par_x.edges.push self
  end

  def end= v
    unless @par_y.nil?
      @par_y.edges.delete {|x| x.id == @id}
    end

    @end = @scene.particles.index {|p| p.id == v}
    @par_y = @scene.particles[@end]
    @par_y.edges.push self
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
