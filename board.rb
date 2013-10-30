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
    bound_condt = row.between?(0,7) && col.between?(0,7)
    nil_condt = row.nil? || col.nil?

    raise ArgumentError if nil_condt || bound_condt

    index_wise << row << col
  end

  def color_set(color)
    color == 'white' ? @white_pieces : @black_pieces
  end

  def other_color_set(color)
    color != 'white' ? @white_pieces : @black_pieces
  end

  def move(color, from, to)
    from, to = parse_move(from), parse_move(to)

    piece = color_set(color).select { |piece| piece.pos == from }[0]

    raise NoPieceError if piece.nil?

    raise NoValidMoveError if piece.valid_moves(self).empty?

    if piece.valid_moves(self).include?(to)
      if self[to].is_a?(Piece)
        if piece.is_a?(Rook) && self[to].is_a?(King) && piece.can_castle?
          piece.castle(self, from, to)
        else
          other_color_set(color).delete_if { |el| el == self[to] }
          move_to(piece, from, to)
        end
      else
        move_to(piece, from, to)
      end
      piece.moved = true
    else
      raise NoValidMoveError
    end
  end

  def move_to(piece, from, to)
    piece.pos = to
    self[from] = nil
    self[to] = piece
  end

  def checkmate?(color)
    checked?(color) && color_set(color).all? { |piece| piece.valid_moves(self).empty? }
  end

  def checked?(color)
    enemy_moves = []

    king = color_set.(color).select { |piece| piece.is_a?(King) }[0]
    other_color_set(color).each { |piece| enemy_moves += piece.moves(self) }

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
    row = ( color == "white" ? 1 : 6 )
    (0..7).each do |col|
      piece = Pawn.new(color, [row, col])
      color_set(color) << piece
      set(piece)
    end
  end

  def row_num(color)
    row = ( color == "white" ? 0 : 7 )
  end

  def place_rooks(color)
    [0,7].each do |col|
      piece = Rook.new(color, [row_num(color), col])
      color_set(color) << piece
      set(piece)
    end
  end

  def place_bishops(color)
    [2,5].each do |col|
      piece = Bishop.new(color, [row_num(color), col])
      color_set(color) << piece
      set(piece)
    end
  end

  def place_knights(color)
    [1,6].each do |col|
      piece = Knight.new(color, [row_num(color), col])
      color_set(color) << piece
      set(piece)
    end
  end

  def place_king(color)
    piece = King.new(color, [row_num(color), 4])
    color_set(color) << piece
    set(piece)
  end

  def place_queen(color)
    piece = Queen.new(color, [row_num(color), 3])
    color_set(color) << piece
    set(piece)
  end

  def display
    # color_idx = -1
#     (0..7).each do |row|
#       (0..7).each do |col|
#         color_idx *= -1
#         next unless self[[row,col]].nil?
#         print (color_idx > 0 ? WHITE_TILE : BLACK_TILE), " "
#       end
#       puts
#     end

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
    temp.white_pieces = color_set('white').dup
    temp.black_pieces = color_set('black').dup
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