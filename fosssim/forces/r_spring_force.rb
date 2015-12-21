require_relative 'r_force'

class RSpringForce < RForce
  attr_accessor :start, :end, :l0, :param_k, :param_b, :spring_color, :par_x,
                :par_y

  def hash_dump
    {:id => @id, :start => @end_points[0], :end => @end_points[1],
     :l0 => @l0, :k => @param_k, :b => @param_b,
     :spring_color => @spring_color}
  end

  def initialize scene, end_points, l0, k=10, b=0
    super scene, true

    @end_points = end_points
    @l0 = l0
    @param_k = k
    @param_b = b

    @start = scene.particles.index {|p| p.id == end_points[0]}
    @end = scene.particles.index {|p| p.id == end_points[1]}

    @par_x = scene.particles[@start]
    @par_x.forces.push self
    @par_y = scene.particles[@end]
    @par_y.forces.push self

    @scene = scene

    @spring = TexPlay.create_blank_image scene.window, *scene.size
    @spring_color = [rand, rand, rand]
  end

  def start= v
    unless @start.nil?
      @par_x.forces.delete {|x| x.id == @id}
    end

    @start = @scene.particles.index {|p| p.id == v}
    @par_x = @scene.particles[@start]
    @par_x.forces.push self
  end

  def reindex_start idx
    @start = idx
  end

  def reindex_end idx
    @end = idx
  end

  def end= v
    unless @end.nil?
      @par_y.forces.delete {|x| x.id == @id}
    end

    @end = @scene.particles.index {|p| p.id == v}
    @par_y = @scene.particles[@end]
    @par_y.forces.push self
  end

  def gradient vec_g
    n_hat = @par_y.pos - @par_x.pos
    l = n_hat.norm

    n_hat /= l
    n_hat *= @param_k * (l - @l0)
    vec_g.inc2 @start, -n_hat
    vec_g.inc2 @end, n_hat

    fdamp = n_hat
    fdamp *= @param_b * fdamp.dot(@par_y.vel - @par_x.vel)
    vec_g.inc2 @start, -fdamp
    vec_g.inc2 @end, fdamp
  end

  def draw
    @spring.clear
    @spring.line @par_x.pos.px, @par_x.pos.py, @par_y.pos.px, @par_y.pos.py,
             :color => @spring_color
    @spring.draw 0, 0, ZOrder::LINES
  end
end
