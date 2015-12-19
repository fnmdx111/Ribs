require_relative 'z_order'
require_relative 'countable'

class RParticle
  include Identifiable

  attr_accessor :pos, :mass, :radius, :vel, :last_dragged_pos
  attr_reader :color, :forces, :edges

  def initialize window, x, y, vx, vy,
                 fixed=false, m=1, clr=:random, radius=15
    super()

    @window = window

    @pos = Vector[x, y]
    @vel = Vector[vx, vy]
    @mass = m
    @color =
        if clr == :random
          [rand, rand, rand]
        else
          clr
        end
    @radius = radius
    @fixed = fixed
    @locked = false
    @dragged = false
    @last_dragged_pos = Vector[0.0, 0.0]

    @image = TexPlay.create_blank_image(window, 2 * @radius, 2 * @radius)
    @image.circle @radius, @radius, @radius, :fill => true, :color => @color,
                  :thickness => 0

    @forces = []
    @edges = []
  end

  def fixed?
    @fixed
  end

  def locked?
    @locked
  end

  def fix
    @fixed = !@fixed
  end

  def lock
    @locked = !@locked
  end

  def drag v=true
    @dragged = v
    if v
      @last_dragged_pos = @pos
    end
  end

  def dragged?
    @dragged
  end

  def god?
    fixed? or locked? or dragged?
  end

  def selected?
    (@window.mouse - @pos).norm <= @radius
  end

  def select!
    @image.clear
    @image.circle @radius, @radius, @radius, :fill => true, :color => @color,
                  :thickness => 0
    @image.circle @radius, @radius, 0.2 * @radius, :fill => true,
                  :color => :random, :thickness => 0
  end

  def unselect!
    @image.clear
    @image.circle @radius, @radius, @radius, :fill => true, :color => @color,
                  :thickness => 0
  end

  def draw
    @image.draw @pos.px - radius, @pos.py - radius, ZOrder::PARTICLES
  end
end
