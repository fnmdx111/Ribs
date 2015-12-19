require_relative 'r_force'

class RSimpleGravityForce < RForce
  def initialize scene, gravity
    super scene, true

    @gravity = gravity
  end

  def energy
    @scene.particles.inject 0.0 do |acc, x|
      acc -= x.mass * (@gravity.dot x.pos)
    end
  end

  def gradient vec_g
    @scene.particles.each_with_index do |x, idx|
      vec_g.inc2 idx, (-x.mass * @gravity)
    end
  end
end
