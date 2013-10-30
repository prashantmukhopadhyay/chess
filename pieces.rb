require './board.rb'

class Piece
  attr_reader :color
  attr_accessor :pos

  def initialize(color, pos)
    @color = color
    @pos = pos
  end

  def valid_moves(board)
    moves(board).select {|move| !move_into_check?(board, move) }
  end

  def move_into_check?(board, tpos)
    tboard = board.dup
    tpiece = nil
    case color
    when 'white'
      tpiece = tboard.white_pieces.select {|piece| piece.pos == pos }[0]
    else
      tpiece = tboard.black_pieces.select {|piece| piece.pos == pos }[0]
    end
    tpiece.pos = tpos
    tboard[pos] = nil
    tboard[tpos] = tpiece
    return true if tboard.checked?(color)
    false
  end

  def dup
    self.class.new(@color, @pos)
  end
end

class SlidingPiece < Piece
  def initialize(color, pos)
    super(color, pos)
  end

  def moves(board)
    possible_moves = []
    self.move_dirs.each do |dir|
      tpos = @pos
      until !tpos[0].between?(0,7) || !tpos[1].between?(0,7)
        x = tpos[0] + dir[0]
        y = tpos[1] + dir[1]
        tpos = [x,y]
        if tpos[0].between?(0,7) && tpos[1].between?(0,7)
          possible_moves << tpos unless board[tpos].is_a?(Piece)
          if !board[tpos].nil?
            possible_moves << tpos if board[tpos].color != self.color
          end
        end
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
      tpos = [x,y]
      if tpos[0].between?(0,7) && tpos[1].between?(0,7)
        possible_moves << tpos unless board[tpos].is_a?(Piece)
        unless board[tpos].nil?
          possible_moves << tpos if board[tpos].color != self.color
        end
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

  def moves(board)
    possible_moves = []

    move_dirs.each do |move|
      tpos = @pos
      tpos = [tpos[0] + move[0], tpos[1] + move[1]]
      if tpos[0].between?(0,7) && tpos[1].between?(0,7)
        case color
        when 'white'
          board.black_pieces.each do |piece|
            next if piece.is_a?(King)
            unless piece.moves(board).include?(tpos)
              if board[tpos].nil?
                possible_moves << tpos
              elsif board[tpos].color != color
                possible_moves << tpos
              end
            end
          end
        else
          board.white_pieces.each do |piece|
            next if piece.is_a?(King)
            unless piece.moves(board).include?(tpos)
              if board[tpos].nil?
                possible_moves << tpos
              elsif board[tpos].color != color
                possible_moves << tpos
              end
            end
          end
        end
      end
    end
    possible_moves.uniq
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

  def moves(board)
    moves = []
    dir = move_dirs
    # pos_to_check = []

    unless (pos[0] + dir[0]).between?(0,7)
      return []
    end

    if pos[0] == 6
      moves << [pos[0] + dir[0] * 2, pos[1] + dir[1]]
    end

    [1,-1].each do |d|
      if (pos[1] + d).between?(0,7)
        diag_pos = [pos[0] + dir[0], pos[1] + d]
        moves << diag_pos if board[diag_pos].is_a?(Piece) && board[diag_pos].color != self
      end
    end

    straight_pos = [pos[0] + dir[0], pos[1] + dir[1]]
    moves << straight_pos if board[straight_pos].nil?

    moves
  end
end

=begin
b = Board.new()
q = Queen.new('black',[0,0])
b[[0,0]] = q
b.black_pieces << q

k = King.new('white',[0,1])
b[[0,1]] = k
b.white_pieces << k
b.display
p b.checked?('white')
=end

=begin
b = Board.new()

b.board = Array.new(8) { Array.new(8) }

q = Queen.new('black',[0,6])
b[[0,6]] = q
b.black_pieces << q

k = King.new('white',[0,0])
b[[0,0]] = k
b.white_pieces << k

p1 = Pawn.new('white',[1,0])
b[[1,0]] = p1
b.white_pieces << p1

p2 = Pawn.new('white',[1,1])
b[[1,1]] = p2
b.white_pieces << p2

b.display
p b.checked?("white")
p b.checkmate?('white')
p k.valid_moves(b)
p p1.valid_moves(b)
p p2.valid_moves(b)
=end