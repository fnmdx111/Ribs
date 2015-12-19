require 'gosu'
require 'texplay'
require 'matrix'

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

class RibsWindow < Gosu::Window
  attr_accessor :mouse

  include Action
  include ActionNewParticle
  include ActionNewSpringForce
  include ActionDragParticle
  include ActionNewSimpleGravity

  def initialize width, height, full_window
    super

    @size = width, height
    @simulate = false

    @scene = RScene.new self, :symplectic, []

    @mouse = Vector[-1.0, -1.0]
    @dummy_particle = RParticle.new self, 0.0, 0.0, 0.0, 0.0
    @selected_particle = @dummy_particle

    test_scene
  end

  def test_scene
    test_par = RParticle.new self, 0, 0, 1.0, 0
    test_par1 = RParticle.new self, 100, 100, 5.0, 0
    @scene.append_particle test_par
    @scene.append_particle test_par1

    test_force = RSimpleGravityForce.new @scene, Vector[20.0, 10.0]
    @scene.append_force test_force
    test_force = RSpringForce.new @scene, [test_par.id, test_par1.id], 50, 20
    @scene.append_force test_force
  end

  def needs_cursor?
    true
  end

  def unselect_current_particle
    @selected_particle.unselect!
    @selected_particle = @dummy_particle
  end

  def particle_at_mouse
    par = @scene.particles.detect &:selected?
    par.nil? ? @dummy_particle : par
  end

  def clear_mouse
    @mouse.px = 0.0
    @mouse.py = 0.0
    @mouse_updated = false
  end

  def update_mouse
    @mouse = Vector[mouse_x, mouse_y]
    @mouse_updated = true
  end

  def button_up id
    super

    case id
      when Gosu::KbQ
        exit 0

      when Gosu::MsLeft
        update_mouse

        unselect_current_particle

        @selected_particle = particle_at_mouse
        @selected_particle.select!

      when Gosu::MsRight
        @mouse = Vector[-1.0, -1.0]

        unselect_current_particle

      when Gosu::KbSpace
        @simulate = !@simulate

      when Gosu::KbF
        @selected_particle.fix

      when Gosu::KbL
        @selected_particle.lock

      when Gosu::KbBackspace
        @scene.remove_particle @selected_particle

      else
        button_up_action id
    end
  end

  def button_down id
    super

    case id
      when Gosu::MsLeft
      else
        button_down_action id
    end
  end

  def draw_bkg_rect
    Gosu::draw_rect 0, 0, *@size, Gosu::Color::WHITE, ZOrder::BKG
  end

  def update
    update_action

    @scene.update 1.0 / 60 if @simulate

    self.caption = "Ribs, time elapsed: #{Gosu.milliseconds / 1000.0}"
  end

  def draw
    draw_bkg_rect

    draw_action
    @scene.particles.each &:draw
    @scene.forces.each &:draw
    @scene.edges.each &:draw
  end
end
