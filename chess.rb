class Piece
  attr_reader :color, :pos

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

  def moves(board)
    possible_moves = []
    self.move_dirs.each do |dir|
      pos = @pos
      until board[pos].is_a?(Piece) || !pos[0].between?(0,7) || !pos[1].between?(0,7)
        x = pos[0] + dir[0]
        y = pos[1] + dir[1]
        pos = [x,y]
        possible_moves << pos
      end
      unless board[pos].nil?
        possible_moves << pos if board[pos].color != self.color
      end
    end
    possible_moves
  end
end

class Queen < SlidingPiece
  attr_reader :char

  @@dirs = [[-1,-1],[-1,1],[1,1],[1,-1],[0,1],[1,0],[0,-1],[-1,0]]

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2655" : "\u265B"
  end

  def move_dirs
    @@dirs
  end
end

class Rook < SlidingPiece
  attr_reader :char

  @@dirs = [[0,1],[1,0],[0,-1],[-1,0]]

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2656" : "\u265C"
  end

  def move_dirs
    @@dirs
  end
end

class Bishop < SlidingPiece
  attr_reader :char

  @@dirs = [[-1,-1],[-1,1],[1,1],[1,-1]]

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2657" : "\u265D"
  end

  def move_dirs
    @@dirs
  end
end

class SteppingPiece < Piece
  def initialize(color, pos)
    super(color, pos)
  end

  def moves(board)
    possible_moves = []
    self.move_dirs.each do |dir|
      x = pos[0] + dir[0]
      y = pos[1] + dir[1]
      pos = [x,y]
      unless board[pos].is_a?(Piece) || !pos[0].between?(0,7) || !pos[1].between?(0,7)
        possible_moves << pos
      end
      unless board[pos].nil?
        possible_moves << pos if board[pos].color != self.color
      end
    end
    possible_moves
  end
end

class Knight < SteppingPiece
  attr_reader :char

  @@dirs = [[1,2],[-1,2],[1,-2],[-1,-2],[2,1],[-2,1],[2,-1],[-2,-1]]

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2658" : "\u265E"
  end

  def move_dirs
    @@dirs
  end
end

class King < SteppingPiece
  attr_reader :char

  @@dirs = [[-1,-1],[-1,1],[1,1],[1,-1],[0,1],[1,0],[0,-1],[-1,0]]

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2654" : "\u265A"
  end

  def move_dirs
    @@dirs
  end

  def moves
  end
end

class Pawn < SteppingPiece
  attr_reader :char

  @@dirs = [[1,0],[-1,0]]

  def initialize(color, pos)
    super(color, pos)
    @char = color == 'white' ? "\u2659" : "\u265F"
  end

  def move_dirs
    return @@dirs[0] if self.color == 'white'
    @@dirs[1]
  end

  def moves
  end
end

class Board
  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8) }
    @white_pieces = []
    @black_pieces = []
    place_pieces
  end

  def checked?(color)
    enemy_moves = []
    king_pos = nil
    if color == 'white'
      king = @white_pieces.select { |piece| piece.is_a?(King) }
      @black_pieces.each do |piece|
        enemy_moves += piece.moves(@board)
      end
    else
      king = @black_pieces.select { |piece| piece.is_a?(King) }
      @white_pieces.each do |piece|
        enemy_moves += piece.moves(@board)
      end
    end
    enemy_moves.include?(king[0].pos)
  end

  def place_pieces
    ['white','black'].each do |color|
      place_pawns(color)
      place_rooks(color)
      place_bishops(color)
      place_knights(color)
      place_king(color)
      place_queen(color)
    end
  end

  def place_pawns(color)
    case color
    when 'white'
      (0..7).each do |col|
        piece = Pawn.new(color, [1,col])
        @white_pieces << piece
        set(piece)
      end
    else
      (0..7).each do |col|
        piece = Pawn.new(color, [6,col])
        @black_pieces << piece
        set(piece)
      end
    end
  end

  def place_rooks(color)
    case color
    when 'white'
      [0,7].each do |col|
        piece = Rook.new(color, [0,col])
        @white_pieces << piece
        set(piece)
      end
    else
      [0,7].each do |col|
        piece = Rook.new(color, [7, col])
        @black_pieces << piece
        set(piece)
      end
    end
  end

  def place_bishops(color)
    case color
    when 'white'
      [2,5].each do |col|
        piece = Bishop.new(color, [0,col])
        @white_pieces << piece
        set(piece)
      end
    else
      [2,5].each do |col|
        piece = Bishop.new(color, [7, col])
        @black_pieces << piece
        set(piece)
      end
    end
  end

  def place_knights(color)
    case color
    when 'white'
      [1,6].each do |col|
        piece = Knight.new(color, [0,col])
        @white_pieces << piece
        set(piece)
      end
    else
      [1,6].each do |col|
        piece = Knight.new(color, [7, col])
        @black_pieces << piece
        set(piece)
      end
    end
  end

  def place_king(color)
    case color
    when 'white'
      piece = King.new(color, [0,4])
      @white_pieces << piece
      set(piece)
    else
      piece = King.new(color, [7,4])
      @black_pieces << piece
      set(piece)
    end
  end

  def place_queen(color)
    case color
    when 'white'
      piece = Queen.new(color, [0,3])
      @white_pieces << piece
      set(piece)
    else
      piece = Queen.new(color, [7,3])
      @black_pieces << piece
      set(piece)
    end
  end

  def display
    @board.each do |row|
      row.each do |tile|
        print "#{tile.char} " unless tile.nil?
        print " " if tile.nil?
      end
      puts
    end
  end

  def set(piece)
    self[piece.pos] = piece
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end

  def []=(pos, value)
    @board[pos[0]][pos[1]] = value
  end
end

b = Board.new()
b.display