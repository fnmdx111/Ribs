require 'nanomsg'

require_relative 'fosssim/patch_mat'
require_relative 'fosssim/patch_num'

require_relative 'fosssim/r_scene'
require_relative 'fosssim/r_particle'
require_relative 'fosssim/r_edge'
require_relative 'fosssim/forces/r_force'
require_relative 'fosssim/forces/r_simple_gravity_force'
require_relative 'fosssim/forces/r_spring_force'

require_relative 'actions/action'
require_relative 'actions/new_particle'
require_relative 'actions/new_spring_force'
require_relative 'actions/drag_particle'
require_relative 'actions/new_simple_gravity'
require_relative 'actions/new_edge'

F = /\d+.\d+/

class Client
  def initialize addr='tcp://localhost:21556'

    @req = NanoMsg::ReqSocket.new
    @req.connect addr
  end

  def cnc_input default, prompt='', type= :to_f
    print "#{prompt} (#{default}) ?> "
    s = gets.strip
    if s.size == 0
      default
    else
      if type == :dont_cast
        s
      else
        s.send type
      end
    end
  end

  def self.to_cmd s
    s.split.join('_').to_sym
  end

  def msg cmd='', **hash
    if cmd.size == 0
      cmd = @cmd
    end

    hash.update :command => Client.to_cmd(cmd)

    @req.send Marshal.dump hash
  end

  def rcv
    Marshal.load @req.recv
  end

  def to_b v
    if v == 'y'
      true
    else
      false
    end
  end

  def input_color prompt='color (:random)'
    print "#{prompt} ?>"

    x = gets.strip
    if x.size == 0
      [rand, rand, rand]
    else
      [x.to_f] + (0..1).collect {gets.strip.to_f}
    end
  end

  def do_par
    case @cmd
      when 'par new'
        msg :mass => cnc_input(1, :mass),
            :radius => cnc_input(15, :radius),
            :fixed => to_b(cnc_input(false, 'fixed (y/n)')),
            :locked => to_b(cnc_input(false, 'locked (y/n)')),
            :x => cnc_input(0.0, :x),
            :y => cnc_input(0.0, :y),
            :vx => cnc_input(0.0, :vx),
            :vy => cnc_input(0.0, :vy),
            :color => input_color

      when 'par remove'
        msg :id => input_id

      when /^par ((pos)|(vel))=/
        msg :id => input_id,
            :x => cnc_input(0.0, :x),
            :y => cnc_input(0.0, :y)

      when /^par ((mass)|(radius)=)/
        msg :id => input_id,
            :x => cnc_input(1, $1)

      when /^par color=/
        msg :id => input_id,
            :color => input_color

      when /^par fix|lock/
        msg :id => input_id
      else
    end
  end

  def input_id prompt= :id
    cnc_input(0, prompt, :to_i)
  end

  def do_edges
    case @cmd
      when 'edge new'
        msg :radius => cnc_input(15, :radius),
            :color => input_color

      when /^edge ((start|end)=)/
        msg :id => input_id,
            $1 => cnc_input(0, $1, :to_i)

      when 'edge color='
        msg :id => input_id,
            :color => input_color

      when 'edge radius='
        msg :id => input_id,
            :radius => cnc_input(15, :radius)

      when 'edge remove'
        msg :id => input_id

      else
    end
  end

  def do_forces
    case @cmd
      when 'simp grav new'
        msg :x => cnc_input(0, :fx),
            :y => cnc_input(0, :fy)
      when 'simp grav gravity='
        msg :id => input_id,
            :x => cnc_input(0, :fx),
            :y => cnc_input(0, :fy)
      when 'spring new'
        msg :x => input_id(:start),
            :y => input_id(:end),
            :k => cnc_input(10, :k),
            :b => cnc_input(0, :b)
      when 'spring k='
        msg :id => input_id,
            :x => cnc_input(10, :k)
      when 'spring b='
        msg :id => input_id,
            :x => cnc_input(0, :b)
      when /^spring ((start|end)=)/
        msg :id => input_id,
            $1=> input_id($1)
      when 'spring l0='
        msg :id => input_id,
            :x => cnc_input(0, :l0)
      when 'spring spring color='
        msg :id => input_id,
            :x => input_color
      when 'force remove'
        msg :id => input_id
      else
    end
  end

  def mainloop
    while true
      print '?> '
      @cmd = gets.strip
      case @cmd
        when /^par.*/
          do_par
        when /^edge.*/
          do_edges
        when /^force.*/
          do_forces
        when /^spring.*/
          do_forces
        when /^simp grav.*/
          do_forces
        when 'coll penalty k'
          msg :x => cnc_input(1000, :k, :to_i)
        when 'coll penalty thickness'
          msg :x => cnc_input(0.001, :thickness)
        when 'coll simple cor'
          msg :x => cnc_input(0.8, :COR)
        when 'q!'
          exit 0
        when 'quit'
          msg
          exit 0
        else
          msg
          puts rcv
      end

    end
  end
end

Client.new.mainloop
