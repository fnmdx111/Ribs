require 'matrix'
require_relative 'collision/r_collision'

class RScene
  attr_accessor :size, :integrator
  attr_reader :energy, :gradient, :window, :edges, :penalty, :impulse_handler,
              :particles, :forces, :collision_method

  VEC2ZERO = Vector[0, 0]
  COLLISION_ORDER = {:penalty => :impulse,
                     :impulse => :no,
                     :no => :penalty}

  def initialize window, integrator= :symplectic, particles=[]
    @window = window
    @particles = particles
    @forces = []
    @edges = []
    @size = [window.width, window.height]
    @integrator = integrator

    @energy = 0.0
    @hessian = Matrix.zero (particles.size * 2)

    @penalty = RPenaltyForce.new self, 0.0001, 1000
    @impulse_handler = RSimpleHandler.new self, 0.75
    @collision_method = :penalty
  end

  def detect_collision! method= :unspecified
    @collision_method = method == :unspecified ?
        RScene::COLLISION_ORDER[@collision_method] :
        method
  end

  def append_force force
    @forces.push force
  end

  def append_particle par
    @particles.push par
  end

  def append_edge edge
    @edges.push edge
  end

  def remove_particle par
    par.forces.each do |f|
      @forces.reject! {|x| x.id == f.id}

      @particles.each do |p|
        next if p.id == par.id
        # remove force instances that reside in other particles' forces field
        # to avoid memory leaking
        p.forces.reject! {|x| x.id == f.id}
      end
    end

    par.edges.each do |e|
      @edges.reject! {|x| x.id == e.id}

      @particles.each do |p|
        next if p.id == par.id
        p.edges.reject! {|x| x.id == e.id}
      end
    end

    idx = @particles.index {|p| p.id == par.id}

    @particles.delete_at idx

    @particles.each_with_index do |p, i|
      p.forces.each do |f|
        case f
          when RSpringForce
            if f.par_x.id == p.id
              f.reindex_start i
            elsif f.par_y.id == p.id
              f.reindex_end i
            end
          else
        end
      end
    end
  end

  def remove_force force
    @particles.each do |p|
      p.forces.reject! {|f| f.id == force.id}
    end
    @forces.reject! {|f| f.id == force.id}
  end

  def remove_edge edge
    @particles.each do |p|
      p.edges.reject! {|e| e.id == edge.id}
    end
    @edges.reject! {|e| e.id == edge.id}
  end

  def accumulate_gradient
    g = Matrix.zero(1, 2 * @particles.size).row 0
    @forces.each {|f| f.gradient g}

    @penalty.gradient g if @collision_method == :penalty

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
    case @integrator
      when :explicit
        explicit_euler_update dt
      when :symplectic
        symplectic_euler_update dt
      else
    end

    if @collision_method == :impulse
      @particles.combination 2 do |ps|
        n = RCollisionDetector::par_par *ps
        @impulse_handler.par_par *ps, n unless n.nil?
      end

      @particles.each do |p|
        @edges.each do |e|
          n = RCollisionDetector::par_edge p, e
          @impulse_handler.par_edge p, e, n unless n.nil?
        end
      end
    end
  end
end
