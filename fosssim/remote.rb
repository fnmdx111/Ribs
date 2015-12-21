require 'nanomsg'
require 'logger'

class RemoteController
  def initialize window, addr='tcp://*:21556'
    @window = window
    @scene = window.scene

    @addr = addr

    @logger = Logger.new STDOUT

    Thread.abort_on_exception = true
    @remote_control_thread = Thread.start { mainloop }
  end

  def index_par h
    @scene.particles.index {|p| p.id == h[:id]}
  end

  def index_force h
    @scene.forces.index {|f| f.id == h[:id]}
  end

  def index_edge h
    @scene.edges.index {|e| e.id == h[:id]}
  end

  def ok
    @rep.send Marshal.dump('ok')
  end

  def err
    @rep.send Marshal.dump('err')
  end

  def do_par h
    if h[:command] == :par_new
      m = h.fetch :mass, 1
      r = h.fetch :radius, 15
      c = h.fetch :color, :random
      f = h.fetch :fixed, false
      l = h.fetch :locked, false
      x = h.fetch :x, 0.0
      y = h.fetch :y, 0.0
      vx = h.fetch :vx, 0.0
      vy = h.fetch :vy, 0.0

      @scene.append_particle RParticle.new(@window,
                                           x, y, vx, vy,
                                           f, l, m, c, r)
      return true
    end

    idx = index_par h
    return false if idx.nil?

    par = @scene.particles[idx]

    case h[:command]
      when /^par_pos=/
        par.pos.px = h[:x]
        par.pos.py = h[:y]
      when /^par_vel=/
        par.vel.px = h[:x]
        par.vel.py = h[:y]
      when /^par_((mass|radius|color)=)/
        par.send $1, h[:x]
      when /^par_(fix|lock)/
        par.send $1
      when :par_remove
        puts h
        @scene.remove_particle par
      else
        return false
    end

    true
  end

  def do_forces h
    if h[:command] == :simp_grav_new
      @scene.append_force(RSimpleGravityForce.new @scene, Vector[h[:x], h[:y]])

      return true
    elsif h[:command] == :spring_new
      ids = [h[:x], h[:y]]
      s, e = ids.collect {|i| @scene.particles.index {|x| x.id == i}}
      return if s.nil? or e.nil?

      dist = (@scene.particles[s].pos - @scene.particles[e].pos).norm
      @scene.append_force(RSpringForce.new @scene, ids, dist, h[:k], h[:b])

      return true
    end

    idx = index_force h
    return false if idx.nil?
    force = @scene.forces[idx]

    case h[:command]
      when :simp_grav_gravity=
        force.gravity.px = h[:x]
        force.gravity.py = h[:y]
      when :spring_k=
        force.param_k = h[:x]
      when :spring_b=
        force.param_b = h[:x]
      when /spring_((start|end|l0|spring_color)=)/
        force.send $1, h[:x]
      when :force_remove
        @scene.remove_force force
      else
        return false
    end

    true
  end

  def do_edges h
    if h[:command] == :edge_new
      r = h.fetch :radius, 15
      c = h.fetch :color, :random
      @scene.append_edge(REdge.new @scene, *h[:ids], r, c)

      return true
    end

    idx = index_edge h
    return false if idx.nil?
    edge = @scene.edges[idx]

    case h[:command]
      when /edge_((radius|color|start|end)=)/
        edge.send $1, h[:x]
      when :edge_remove
        @scene.remove_edge edge
      else
        return false
    end

    true
  end

  def mainloop
    @rep = NanoMsg::RepSocket.new
    @rep.bind @addr

    while true
      puts "waiting"
      h = Marshal.load @rep.recv
      puts "recv -- #{h[:command]}\\#{h.size - 1}"

      case h[:command]
        when /^force.*/
          ok if do_forces h
        when /^spring.*/
          ok if do_forces h
        when /^simp_grav.*/
          ok if do_forces h
        when /^par.*/
          ok if do_par h
        when /^edge.*/
          ok if do_edges h
        when :coll_penalty_k
          @scene.penalty.param_k = h[:x]
          ok
        when :coll_penalty_thickness
          @scene.penalty.thickness = h[:x]
          ok
        when :coll_simple_cor
          @scene.impulse.cor = h[:x]
          ok
        when :list_forces
          @rep.send Marshal.dump(@scene.forces.collect {|f| f.hash_dump})
        when :list_par
          @rep.send Marshal.dump(@scene.particles.collect {|p| p.hash_dump})
        when :list_edges
          puts Marshal.dump @scene.edges.collect {|e| e.hash_dump}
          @rep.send Marshal.dump(@scene.edges.collect {|e| e.hash_dump})
        when :show_penalty
          @rep.send Marshal.dump(@scene.penalty.hash_dump)
        when :show_simple_coll
          @rep.send Marshal.dump(@scene.impulse_handler.hash_dump)
        when :quit
          exit 0
        when :coll_change
          @scene.detect_collision!
          ok
        when :pause
          @window.simulate = !@window.simulate
          ok
        else
          @logger.warn "unknown command #{h[:command]}"
          err
      end
    end
  end
end
