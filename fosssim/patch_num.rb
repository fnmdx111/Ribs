
class Numeric
  def square
    self * self
  end

  def sqrt
    Math.sqrt self
  end
end

class Float
  EQU_EPSILON = 0.001
  def equ? v
    (self - v).abs == EQU_EPSILON
  end
end
