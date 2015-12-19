require_relative 'r_force'

class RSpringForce < RForce
  def initialize scene, end_points, l0, k=10, b=0
    super scene, true

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
  end

  def energy
    l = (@par_x.pos - @par_y.pos).norm

    0.5 * @param_k * (l - @l0).square
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

  def hessian_x mat_h
    n_hat = @par_y.pos - @par_x.pos
    l = n_hat.norm
    n_hat /= l

    hess = n_hat.square
    hess += (l - @l0) * (Matrix.I(2) - hess) / l
    hess *= @param_k

    mat_h.inc22 @start, @start, hess
    mat_h.inc22 @end, @end, hess
    mat_h.inc22 @start, @end, -hess
    mat_h.inc22 @end, @start, -hess

    dv = @par_y.vel - @par_x.vel
    hess = dv.covector.transpose * n_hat.covector

    t = n_hat.dot dv
    hess.row_size.times do |x|
      hess[x, x] += t
    end
    hess -= hess * n_hat.square
    hess *= -@param_b / l

    mat_h.inc22 @start, @start, -hess
    mat_h.inc22 @end, @end, -hess
    mat_h.inc22 @start, @end, hess
    mat_h.inc22 @end, @start, hess
  end

  def hessian_v mat_h
    n_hat = @par_y.pos - @par_x.pos
    l = n_hat.norm
    n_hat /= l

    hess = @param_b * n_hat.square
    mat_h.inc22 @start, @start, hess
    mat_h.inc22 @end, @end, hess
    mat_h.inc22 @start, @end -= hess
    mat_h.inc22 @end, @start -= hess
  end

  def draw
    width = (@par_x.pos.px - @par_y.pos.px).abs
    height = (@par_x.pos.py - @par_y.pos.py).abs
    return if width == 0 or height == 0

    img = TexPlay.create_blank_image @scene.window, width, height
    img.line @par_x.pos.px, @par_x.pos.py, @par_y.pos.px, @par_y.pos.py,
             :color => :black
    img.draw @par_x.pos.px, @par_x.pos.py, ZOrder::PARTICLES
  end
end
