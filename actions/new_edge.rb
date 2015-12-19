module ActionNewEdge
  def initialize *args
    super

    setup_key Gosu::KbE, :start_new_edge, :update_new_edge, :end_new_edge
  end

  def start_new_edge
    clear_mouse

    @stage = 0
    @ane_end_points = []
  end

  def update_new_edge
    @draw_point2 = Vector[mouse_x, mouse_y]
    return unless @mouse_updated

    if @stage == 0
      par = particle_at_mouse
      return if par.nil?

      @ane_end_points.push par
      @draw_point1 = par.pos

      clear_mouse
      @stage += 1
    elsif @stage == 1
      par = particle_at_mouse
      return if par.nil?

      @ane_end_points.push par
      @ane_the_edge = REdge.new @scene, @ane_end_points.collect(&:id)
    end
  end

  def end_new_edge
    clear_mouse

    @scene.append_edge @ane_the_edge

    @ane_the_edge = nil
    @draw_point1 = nil
    @draw_point2 = nil
    @ane_end_points = nil
    @stage = 0
  end
end
