require_relative '../countable'
require_relative '../z_order'

class RForce
  attr_reader :scene
  attr_accessor :enabled, :counter, :id

  @counter = 0

  def initialize scene, enabled
    @@counter ||= 0
    super()

    @scene = scene
    @enabled = enabled
    @@counter += 1
    @id = @@counter
  end

  def energy; end

  def gradient vec_g; end

  def hessian_x mat_h; end

  def hessian_v mat_h; end

  def draw; end

  def hash_dump; end
end
