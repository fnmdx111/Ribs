require_relative '../countable'
require_relative '../z_order'

class RForce
  attr_reader :scene
  attr_accessor :enabled

  include Identifiable

  def initialize scene, enabled
    super()

    @scene = scene
    @enabled = enabled
  end

  def energy; end

  def gradient vec_g; end

  def hessian_x mat_h; end

  def hessian_v mat_h; end

  def draw; end
end
