module Action
  def initialize *args
    super
    @keys = {}
    @activated_key = nil

    @draw_point1 = nil
    @draw_point2 = nil
  end

  def setup_key key, start_method, update_method, end_method
    @keys[key] = [start_method, update_method, end_method]
  end

  def button_up_action id
    return unless @keys.include? id

    self.send @keys[id][2] if @keys.include? id
    @activated_key = nil
    @draw_point1 = nil
    @draw_point2 = nil
  end

  def button_down_action id
    return unless @keys.include? id

    self.send @keys[id][0] if @keys.include? id
    @activated_key = id
  end

  def update_action
    self.send @keys[@activated_key][1] unless @activated_key.nil?
  end

  def draw_action
    return if @draw_point1.nil? or @draw_point2.nil?

    width = (@draw_point1.px - @draw_point2.px).abs
    height = (@draw_point1.py - @draw_point2.py).abs

    return if width.to_i == 0 or height.to_i == 0

    TexPlay.create_blank_image(self, width, height)
        .line(@draw_point1.px, @draw_point1.py,
              @draw_point2.px, @draw_point2.py,
              :color => :random, :thickness => 10)
        .draw(@draw_point1.px, @draw_point1.py, ZOrder::PARTICLES)
  end
end
