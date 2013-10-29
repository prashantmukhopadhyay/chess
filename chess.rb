WHITE_PIECES = { king => "\u2654", queen => "\u2655",
                rook => "\u2656", bishop => "\u2657",
                knight => "\u2658", pawn => "\u2659" }

BLACK_PIECES = { king => "\u265A", queen => "\u265B",
                rook => "\u265C", bishop => "\u265D",
                knight => "\u265E", pawn => "\u265F" }

class Piece
  def initialize(color, pos)
    @color = color
    @pos = pos
  end

  def moves
  end

  def move
  end
end

class SlidingPiece < Piece
  def initialize(color, pos)
    super(color, pos)
  end

  def moves
  end
end

class Queen < SlidingPiece
  attr_reader :char

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2655" : "\u265B"
  end

  # def moves
  # end
end

class Rook < SlidingPiece
  attr_reader :char

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2656" : "\u265C"
  end
end

class Bishop < SlidingPiece
  attr_reader :char

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2657" : "\u265D"
  end
end

class SteppingPiece < Piece
end

class Knight < SteppingPiece
  attr_reader :char

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2658" : "\u265E"
  end
end

class King < SteppingPiece
  attr_reader :char

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2654" : "\u265A"
  end
end

class Pawn < SteppingPiece
  attr_reader :char

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2659" : "\u265F"
  end
end

end
