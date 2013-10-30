require './pieces.rb'
require './board.rb'

class HumanPlayer
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn
    move = []
    puts "From where?"
    move << gets.chomp
    puts "To where?"
    move << gets.chomp
    move
  end
end

class Game
  def initialize
    @board = Board.new
    @players = [HumanPlayer.new('white'), HumanPlayer.new('black')]
  end

  def play
    until @board.checkmate?('black') || @board.checkmate?('white')
      @players.each do |player|
        @board.display
        begin
          puts "#{player.color.capitalize} Player's Turn"
          m = player.play_turn
          @board.move(player.color, m[0], m[1])
        rescue ArgumentError
          p "Enter a valid coordinates!"
          retry
        rescue NoPieceError
          p "Select one of your pieces!"
          retry
        rescue NoValidMoveError
          p "Cannot move there!"
          retry
        end
      end
    end
    puts "#{@board.checkmate?('white') ? "Black" : "White"} WINS!"

    @board.display
  end
end



g = Game.new
g.play