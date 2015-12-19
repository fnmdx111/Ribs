module ActionNewSimpleGravity
  def initialize *args
    super

    setup_key Gosu::KbG, :start_new_simple_gravity_force,
        :update_new_simple_gravity_force,
        :end_new_simple_gravity_force
  end

  def start_new_simple_gravity_force
    @stage = 0
  end

  def update_new_simple_gravity_force
    @draw_point2 = Vector[mouse_x, mouse_y]

    return unless @mouse_updated

    if @stage == 0
      @ansg_point1 = @mouse.map(&:to_f)
      @draw_point1 = @mouse

      clear_mouse

      @stage += 1
    elsif @stage == 1
      force = RSimpleGravityForce.new @scene, -@ansg_point1 + @mouse
      @scene.append_force force

      @stage += 1
    end
  end

  def end_new_simple_gravity_force
    clear_mouse

    @ansg_point1 = nil
    @draw_point1 = nil
    @draw_point2 = nil
    @stage = 0
  end
end
