module ActionDragParticle
  def initialize *args
    super

    setup_key Gosu::KbD, :start_dragging, :update_dragging, :end_dragging
  end

  def start_dragging
    @stage = 0
  end

  def update_dragging
    @draw_point2 = Vector[mouse_x, mouse_y]

    if @stage == 0
      return unless @mouse_updated

      par = particle_at_mouse
      return if par.nil?

      @draw_point1 = par.pos

      @adp_par = par

      clear_mouse

      @stage += 1
    elsif @stage == 1
      @adp_par.pos.px = mouse_x
      @adp_par.pos.py = mouse_y
    end
  end

  def end_dragging
    @adp_par = nil
    @draw_point1 = nil
    @draw_point2 = nil
    @stage = 0
  end
end
