module ActionDragParticle
  def initialize *args
    super

    setup_key Gosu::KbD, :start_dragging, :update_dragging, :end_dragging
  end

  def start_dragging
    clear_mouse

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
      @adp_par.drag

      clear_mouse

      @stage += 1
    elsif @stage == 1
      if @mouse_updated
        par = particle_at_mouse
        unless par.nil?
          @adp_par.drag false
          @adp_par = par
          @adp_par.drag
          @draw_point1 = par.pos
        end
        clear_mouse
      end

      @adp_par.vel = -@adp_par.pos + Vector[mouse_x, mouse_y]
      @adp_par.pos.px = mouse_x
      @adp_par.pos.py = mouse_y
    end
  end

  def end_dragging
    @adp_par.drag false
    @adp_par = nil
    @draw_point1 = nil
    @draw_point2 = nil
    @stage = 0
  end
end
