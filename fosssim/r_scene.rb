require 'matrix'

class RScene
  attr_accessor :size, :particles, :integrator, :forces
  attr_reader :energy, :gradient, :hessian_v, :hessian_x, :window

  VEC2ZERO = Vector[0, 0]

  def initialize window, integrator= :symplectic, particles=[]
    @window = window
    @particles = particles
    @forces = []
    @edges = []
    @size = [window.width, window.height]
    @integrator = integrator

    @energy = 0.0
    @hessian = Matrix.zero (particles.size * 2)
  end

  def append_force force
    @forces.push force
  end

  def append_particle par
    @particles.push par
  end

  def remove_particle par
    par.forces.each {|f| @forces.reject! {|x| x.id == f.id}}
    par.edges.each {|e| @edges.reject! {|x| x.id == e.id}}

    idx = @particles.index {|p| p.id == par.id}

    @particles.delete_at idx
  end

  def accumulate_gradient
    g = Matrix.zero(1, 2 * @particles.size).row 0
    @forces.each {|f| f.gradient g}
    -1.0 * g
  end

  def explicit_euler_update dt
    g = accumulate_gradient

    @particles.each_with_index do |par, idx|
      g.set2 idx, VEC2ZERO if par.fixed?
    end
    @particles.each do |par|
      par.vel.set2 0, VEC2ZERO if par.locked?
    end

    g.div_elem_wise @particles.collect_concat {|x| [x.mass, x.mass]}
    @particles.each_with_index do |par, i|
      if par.locked?
      elsif par.dragged?
      else
        par.pos += par.vel * dt
        par.vel += g.get2(i) * dt
      end
    end
  end

  def symplectic_euler_update dt
    g = accumulate_gradient

    @particles.each_with_index do |par, idx|
      g.set2 idx, VEC2ZERO if par.fixed?
    end

    g.div_elem_wise @particles.collect_concat {|p| [p.mass, p.mass]}
    @particles.each_with_index do |p, i|
      if p.locked?
      elsif p.dragged?
      else
        p.vel += dt * g.get2(i)
        p.pos += dt * p.vel
      end
    end
  end

  def update dt
    if @integrator == :explicit
      explicit_euler_update dt
    elsif @integrator == :implicit
      linearized_implicit_euler_update dt
    elsif @integrator == :symplectic
      symplectic_euler_update dt
    end
  end
end
