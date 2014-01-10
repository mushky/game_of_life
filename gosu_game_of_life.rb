# Gosu File

require 'gosu'
require_relative 'game_of_life.rb'

class GameOfLifeWindow < Gosu::Window
	def initialize(height=1000, width=1000)
		
		@height = height
		@width  = width
		super height, width, false
		self.caption = "The Game Of Life"

    # Colors
    @background = Gosu::Color.new(0xff000000)
    @alive = Gosu::Color.new(0xff00ffff)
    @dead = Gosu::Color.new(0xffff0000)

    # Game world
    @rows = height/10
    @cols = width/10
    @world = World.new(@cols, @rows) 
    @game = Game.new(@world)
    @row_height = height/@rows
    @col_width = width/@cols
    @game.world.randomly_populate

    @generation = 0
  end

  def update
    @game.tick!
    @generation += 1
    puts "Generation Number: #{@generation}"
  end

  def draw
    draw_background
    @game.world.cells.each do |cell|
      if cell.alive?
        draw_quad(cell.x * @col_width, cell.y * @row_height, @alive,
                  cell.x * @col_width + (@col_width), cell.y * @row_height, @alive,
                  cell.x * @col_width + (@col_width), cell.y * @row_height + (@row_height), @alive,
                  cell.x * @col_width, cell.y * @row_height + (@row_height), @alive)
      else
        draw_quad(cell.x * @col_width, cell.y * @row_height, @dead,
                  cell.x * @col_width + (@col_width), cell.y * @row_height, @dead,
                  cell.x * @col_width + (@col_width), cell.y * @row_height + (@row_height), @dead,
                  cell.x * @col_width, cell.y * @row_height + (@row_height), @dead)
      end
    end
  end

  def button_down(id)
    case id
    when Gosu::KbSpace
      @game.world.randomly_populate
    when Gosu::KbEscape
      close
    end
  end

  def needs_cursor?
    true
  end

  def draw_background
    draw_quad(0, 0, @background,
              width, 0, @background,
              width, height, @background,
              0, height, @background)
  end
end

window = GameOfLifeWindow.new
window.show