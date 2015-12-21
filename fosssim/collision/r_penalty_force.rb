require_relative '../forces/r_force'

class RPenaltyForce < RForce
  attr_accessor :thickness, :param_k
  def initialize scene, thickness, k
    @scene = scene
    @thickness = thickness
    @param_k = k
  end

  def hash_dump
    {:thickness => @thickness, :k => @param_k}
  end

  def gradient g
    @scene.particles.combination 2 do |ps|
      par_par_gradient g, *ps
    end

    @scene.particles.each do |p|
      @scene.edges.each do |e|
        par_edge_gradient g, p, e unless [e.par_x, e.par_y].any? { |x| x.id == p.id }
      end
    end
  end

  def par_par_gradient g, p1, p2
    n = p2.pos - p1.pos
    n_hat = n.normalize

    if n.norm < p1.radius + p2.radius + @thickness
      idx1, idx2 = [p1, p2].collect do |x|
        @scene.particles.index { |p| p.id == x.id }
      end

      k = @param_k * (n.norm - p1.radius - p2.radius - @thickness) * n_hat

      g.inc2 idx1, -k
      g.inc2 idx2, k
    end
  end

  def par_edge_gradient g, p, e
    x3_x2 = e.par_y.pos - e.par_x.pos
    alpha = ((p.pos - e.par_x.pos).dot(x3_x2) / x3_x2.dot(x3_x2)).clamp

    n = e.par_x.pos + alpha * x3_x2 - p.pos
    n_hat = n.normalize

    if n.norm < p.radius + e.radius + @thickness
      idx1, idx2, idx3 = [p, e.par_x, e.par_y].collect do |x|
        @scene.particles.index { |t| t.id == x.id }
      end

      k = @param_k * (n.norm - p.radius - e.radius - @thickness) * n_hat
      g.inc2 idx1, -k
      g.inc2 idx2, k * (1 - alpha)
      g.inc2 idx3, k * alpha
    end
  end
end
