require_relative 'action'

module ActionNewParticle
  def initialize *args
    super

    @vel_coeff = 0.5
    setup_key Gosu::KbP, :start_new_particle, :update_new_particle,
              :end_new_particle
  end

  def start_new_particle
    @stage = 0
    @temp_par = RParticle.new self, 0.0, 0.0, 0.0, 0.0
  end

  def update_new_particle
    @draw_point2 = Vector[mouse_x, mouse_y]

    return unless @mouse_updated

    if @stage == 0
      @temp_par.pos = @mouse.map(&:to_f)
      @draw_point1 = @temp_par.pos

      clear_mouse

      @stage += 1
    elsif @stage == 1
      @temp_par.vel = (@mouse - @temp_par.pos) * @vel_coeff

      @scene.append_particle @temp_par

      @stage += 1
    end
  end

  def end_new_particle
    clear_mouse

    @temp_par = nil
    @draw_point1 = nil
    @draw_point2 = nil
  end
end
