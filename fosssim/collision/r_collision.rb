module RCollisionDetector
  def self.par_par p1, p2
    n = p1.pos - p2.pos
    if n.norm < p1.radius + p2.radius
      rel_vel = (p1.vel - p2.vel).dot n
      n if rel_vel > 0
    end
  end

  def self.par_edge p, e
    x3_x2 = e.par_y.pos - e.par_x.pos
    alpha = ((p.pos - e.par_x.pos).dot(x3_x2) / x3_x2.dot(x3_x2)).clamp

    d = e.par_x.pos + alpha * x3_x2
    n = d - p.pos
    if n.norm < p.radius + e.radius
      rel_vel = (p.vel - e.par_x.vel\
                 - alpha * (e.par_y.vel - e.par_x.vel)).dot n

      n if rel_vel > 0
    end
  end
end

require_relative 'r_simple_handler'
require_relative 'r_penalty_force'
