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
        m = player.play_turn
        @board.move(player.color, m[0], m[1])
      end
    end
  end
end

g = Game.new
g.play