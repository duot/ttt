class String
  def parenthesize
    "(#{self})"
  end
end

class Array
  def joinor(conjunction = 'or', separator = ', ')
    ar = self
    return ar.join " #{conjunction} " if ar.count <= 2
    *body, tail = ar
    "#{body.join separator}#{separator}#{conjunction} #{tail}"
  end
end
