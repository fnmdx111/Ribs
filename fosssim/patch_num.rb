
class Numeric
  def square
    self * self
  end

  def sqrt
    Math.sqrt self
  end

  def clamp min=0.0, max=1.0
    [[self, min].max, max].min
  end
end

class Float
  EQU_EPSILON = 0.001
  def equ? v
    (self - v).abs == EQU_EPSILON
  end
end
