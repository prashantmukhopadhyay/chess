require './pieces.rb'

class Board
  WHITE_TILE = "\u25A1"
  BLACK_TILE = "\u25A0"
  COLUMNS = %w[a b c d e f g h]

  attr_accessor :board, :white_pieces, :black_pieces

  def initialize
    @board = Array.new(8) { Array.new(8) }
    @white_pieces = []
    @black_pieces = []
    place_pieces
  end

  def parse_move(move)
    index_wise = []
    components = move.split('')

    row = components[1].to_i - 1
    col = COLUMNS.index(components[0])

    raise ArgumentError if row.nil? || col.nil? || !row.between?(0,7) || !col.between?(0,7)

    index_wise << row
    index_wise << col
    index_wise
  end

  def move(color, from, to)
    from = parse_move(from)
    to = parse_move(to)

    piece = nil
    color_set = (color == 'white' ? @white_pieces : @black_pieces)

    piece = color_set.select {|piece| piece.pos == from }[0]

    raise NoPieceError if piece == nil
    p piece.valid_moves(self)
    raise NoValidMoveError if piece.valid_moves(self).empty?

    if piece.valid_moves(self).include?(to)
      piece.pos = to
      self[from] = nil
      self[to] = piece
      piece.moved = true
    end
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
    color_set = (color == 'white' ? @white_pieces : @black_pieces)
    row = ( color == "white" ? 1 : 6 )

    (0..7).each do |col|
      piece = Pawn.new(color, [row, col])
      color_set << piece
      set(piece)
    end
  end

  def place_rooks(color)
    color_set = (color == 'white' ? @white_pieces : @black_pieces)
    row = ( color == "white" ? 0 : 7 )

    [0,7].each do |col|
      piece = Rook.new(color, [row, col])
      color_set << piece
      set(piece)
    end
  end

  def place_bishops(color)
    color_set = (color == 'white' ? @white_pieces : @black_pieces)
    row = ( color == "white" ? 0 : 7 )

    [2,5].each do |col|
      piece = Bishop.new(color, [row, col])
      color_set << piece
      set(piece)
    end
  end

  def place_knights(color)
    color_set = (color == 'white' ? @white_pieces : @black_pieces)
    row = ( color == "white" ? 0 : 7 )

    [1,6].each do |col|
      piece = Knight.new(color, [row, col])
      color_set << piece
      set(piece)
    end
  end

  def place_king(color)
    color_set = (color == 'white' ? @white_pieces : @black_pieces)
    row = ( color == "white" ? 0 : 7 )

    piece = King.new( color, [row, 4] )
    color_set << piece
    set(piece)
  end

  def place_queen(color)
    color_set = (color == 'white' ? @white_pieces : @black_pieces)
    row = ( color == "white" ? 0 : 7 )

    piece = Queen.new( color, [row, 3] )
    color_set << piece
    set(piece)
  end

  def display
    print "  |"
    COLUMNS.each do |letter|
      print letter + " "
    end
    puts
    puts "-" * 18
    @board.each_with_index do |row, y|
      print "#{y+1} |"
      row.each_with_index do |tile, x|
        print "#{tile.char} " unless tile.nil?
        if tile.nil?
          if y % 2 == 0
            if x % 2 == 0
              print WHITE_TILE + " "
            else
              print BLACK_TILE + " "
            end
          else
            if x % 2 == 0
              print BLACK_TILE + " "
            else
              print WHITE_TILE + " "
            end
          end
        end
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

class NoPieceError < StandardError
end


class NoValidMoveError < StandardError
end

class Array
  def dd_map
    map { |el| el.is_a?(Array) ? el.dd_map : el.dup unless el.nil? }
  end
end