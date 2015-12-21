class RSimpleHandler
  attr_accessor :cor

  def hash_dump
    {:cor => @cor}
  end

  def initialize scene, cor
    @scene = scene
    @cor = cor
  end

  def par_par p1, p2, n
    n_hat = n.normalize
    c_factor = (1.0 + @cor) / 2.0

    m1, m2 = [p1, p2].collect { |p| p.god? ? Float::INFINITY : p.mass }
    numerator = 2 * c_factor * (p2.vel - p1.vel).dot(n_hat)
    denom1 = 1 + m1 / m2
    denom2 = m2 / m1 + 1

    p1.vel += numerator / denom1 * n_hat unless p1.god?
    p2.vel -= numerator / denom2 * n_hat unless p2.god?
  end

  def par_edge p, e, n
    n_hat = n.normalize

    x3_x2 = e.par_y.pos - e.par_x.pos

    alpha = ((p.pos - e.par_x.pos).dot(x3_x2) / x3_x2.dot(x3_x2)).clamp
    edge_vel = e.par_x.vel + alpha * (e.par_y.vel - e.par_x.vel)
    c_factor = (1.0 + @cor) / 2.0

    m1, m2, m3 = [p, e.par_x, e.par_y].collect { |par|
      par.god? ? Float::INFINITY : par.mass
    }

    numerator = 2 * c_factor * (edge_vel - p.vel).dot(n_hat)
    denom1 = 1.0 + (1 - alpha).square * m1 / m2 + alpha.square * m1 / m3
    denom2 = m2 / m1 + (1 - alpha).square + alpha.square * m2 / m3
    denom3 = m3 / m1 + (1 - alpha).square * m3 / m2 + alpha.square

    p.vel += numerator / denom1 * n_hat unless p.god?
    e.par_x.vel -= (1.0 - alpha) * numerator / denom2 * n_hat unless e.par_x.god?
    e.par_y.vel -= alpha * numerator / denom3 * n_hat unless e.par_y.god?
  end
end
