require './pieces.rb'

class Board
  attr_accessor :board, :white_pieces, :black_pieces

  def initialize
    @board = Array.new(8) { Array.new(8) }
    @white_pieces = []
    @black_pieces = []
    place_pieces
  end

  def move(color, from, to)
    piece = nil
    case color
    when 'white'
      piece = white_pieces.select {|piece| piece.pos == from }[0]
    else
      piece = black_pieces.select {|piece| piece.pos == from }[0]
    end
    p self[from]
    p piece
    if piece.valid_moves(self).include?(to)
      piece.pos = to
      self[from] = nil
      self[to] = piece
    end
    piece
  end

  def checkmate?(color)
    case color
    when 'white'
      checked?(color) && @white_pieces.all? { |piece| piece.valid_moves(self).empty? }
    else
      checked?(color) && @black_pieces.all? { |piece| piece.valid_moves(self).empty? }
    end
  end

  def checked?(color)
    enemy_moves = []
    king_pos = nil
    if color == 'white'
      king = @white_pieces.select { |piece| piece.is_a?(King) }[0]
      @black_pieces.each do |piece|
        enemy_moves += piece.moves(self)
      end
    else
      king = @black_pieces.select { |piece| piece.is_a?(King) }[0]
      @white_pieces.each do |piece|
        enemy_moves += piece.moves(self)
      end
    end
    enemy_moves.include?(king.pos)
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
        print "  " if tile.nil?
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

  def dup
    temp = Board.new
    temp.board = @board.dd_map
    temp.white_pieces = @white_pieces.dd_map
    temp.black_pieces = @black_pieces.dd_map
    temp
  end
end

class Array
  def dd_map
    map { |el| el.is_a?(Array) ? el.dd_map : el.dup unless el.nil? }
  end
end