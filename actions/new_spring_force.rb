require_relative 'action'

module ActionNewSpringForce
  def initialize *args
    super

    setup_key Gosu::KbS, :start_new_spring_force, :update_new_spring_force,
              :end_new_spring_force
  end

  def start_new_spring_force
    clear_mouse

    @stage = 0
    @ansf_end_points = []
  end

  def update_new_spring_force
    @draw_point2 = Vector[mouse_x, mouse_y]

    return unless @mouse_updated

    if @stage == 0
      par = particle_at_mouse
      return if par.nil?

      @ansf_end_points.push par
      @draw_point1 = par.pos

      clear_mouse

      @stage += 1
    elsif @stage == 1
      par = particle_at_mouse
      return if par.nil?

      @ansf_end_points.push par

      the_force = RSpringForce.new @scene, @ansf_end_points.collect {|p| p.id},
                                   (@ansf_end_points[0].pos
                                   - @ansf_end_points[1].pos).norm
      @scene.append_force the_force

      @stage += 1
    end
  end

  def end_new_spring_force
    clear_mouse

    @ansf_end_points = nil
    @draw_point1 = nil
    @draw_point2 = nil
    @stage = 0
  end
end
