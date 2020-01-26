class String
  def parenthesize
    "(#{self})"
  end
end

class Array
  def joinor(conjunction = 'or', separator = ', ')
    return self.join " #{conjunction} " if self.count <= 2
    *body, tail = self
    "#{body.join separator}#{separator}#{conjunction} #{tail}"
  end
end
