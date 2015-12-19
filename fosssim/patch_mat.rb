require 'matrix'

class Vector
  def inc2 idx, vec2
    self[2 * idx] += vec2[0]
    self[2 * idx + 1] += vec2[1]
    self
  end

  def set2 idx, vec2
    self[2 * idx] = vec2[0]
    self[2 * idx + 1] = vec2[1]
    self
  end

  def get2 idx
    Vector[self[2 * idx], self[2 * idx + 1]]
  end

  def square
    self.covector.transpose * self.covector
  end

  def px
    self[0]
  end

  def px= v
    self[0] = v
  end

  def py
    self[1]
  end

  def py= v
    self[1] = v
  end

  def div_elem_wise other
    self.each_with_index {|_, i| self[i] /= other[i]}
  end
end

class Matrix
  def inc22 idx_row, idx_col, mat2
    self[idx_row * 2, idx_col * 2] += mat2[0, 0]
    self[idx_row * 2, idx_col * 2 + 1] += mat2[0, 1]
    self[idx_row * 2 + 1, idx_col * 2] += mat2[1, 0]
    self[idx_row * 2 + 1, idx_col * 2 + 1] += mat2[1, 1]
    self
  end
end
