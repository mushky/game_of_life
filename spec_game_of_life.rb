#spec file

require 'rspec'
require_relative 'game_of_life'

# Let: When you have to assign a variable instead of using a before block to create an instance variable.
# This is advanced memory saving stuff!
describe 'Game of Life' do
  let!(:cell) { Cell.new(1,1) }
  let!(:world) { World.new }
  let!(:game) { Game.new(world, [[1, 1]]) }
  let!(:window) { GameOfLifeWindow.new }

  context 'Ga me' do
    subject { game }

    it 'Initializes a new game' do
      subject.world.is_a?(World).should be_true
      subject.world.cell_board[1][1].alive.should be_true
    end
  end

  context 'World' do
    subject { World.new }

    it 'Responds to the appropriate methods' do
      subject.should respond_to(:rows)
      subject.should respond_to(:cols)
      subject.should respond_to(:cell_board)
      subject.should respond_to(:cells)
      subject.should respond_to(:randomly_populate)
      subject.should respond_to(:live_neighbours_around_cell)
      subject.should respond_to(:live_cells)
    end

    it 'Initializes the cell board properly' do
      subject.cell_board.each do |row|
        row.is_a?(Array).should be_true
        row.each do |element|
          element.is_a?(Cell).should be_true
          element.alive.should be_false
        end
    end

    it 'Can count cells' do
      subject.cells.count.should == subject.rows * subject.cols
    end

    it 'Can count live cells' do
      subject.live_cells.count.should == 0
      subject.cell_board[1][1].alive = true
      subject.live_cells.count.should == 1
    end

    it 'Detects live neighbour to the north' do
      subject.cell_board[cell.y - 1][cell.x].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects live neighbour to the north-east' do
      subject.cell_board[cell.y - 1][cell.x + 1].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects live neighbour to the east' do
      subject.cell_board[cell.y][cell.x + 1].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects live neighbour to the south-east' do
      subject.cell_board[cell.y + 1][cell.x + 1].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects live neighbour to the south' do
      subject.cell_board[cell.y + 1][cell.x].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects live neighbour to the south-west' do
      subject.cell_board[cell.y + 1][cell.x - 1].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects live neighbour to the west' do
      subject.cell_board[cell.y][cell.x - 1].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects live neighbour to the north-west' do
      subject.cell_board[cell.y - 1][cell.x - 1].alive = true
      subject.live_neighbours_around_cell(cell).count.should == 1
    end

    it 'Detects no live neighbours' do
      subject.live_neighbours_around_cell(subject.cell_board[1][1]).should == []
    end

    it 'Counts live and dead cells' do
      subject.randomly_populate
      (subject.live_cells.count + subject.dead_cells.count).should == subject.cells.count
    end
    
    it 'Should randomly populates the world' do
      subject.live_cells.should == []
      subject.randomly_populate
      subject.live_cells.should_not == []
    end

    it 'Should count live and dead cells' do
      subject.randomly_populate
      (subject.live_cells.count + subject.dead_cells.count).should == subject.cells.count
    end

  end

  context 'Cell' do
    subject { Cell.new }

    it 'Initializes a new cell object' do
      subject.alive.should be_false
    end

    it 'Responds to the set methods' do
      subject.should respond_to(:x)
      subject.should respond_to(:y)
      subject.should respond_to(:alive)
    end
  end

  context 'Rules' do

    context 'Rule #1: Any live cell with fewer than two live neighbours dies, as if caused by under-population.' do
      it 'Kills live cell with no neighbours' do
        game.world.cell_board[1][1].should be_alive
        game.tick!
        game.world.cell_board[1][1].should be_dead
      end

      it 'Kills live cell with 1 live neighbour' do
        game = Game.new(world, [[0, 1], [1, 1]])
        game.tick!
        game.world.cell_board[0][1].should be_dead
        game.world.cell_board[1][1].should be_dead
      end

      it 'Doesnt kill live cell with 2 neighbours' do
        game = Game.new(world, [[0, 1], [1, 1], [2, 1]])
        game.tick!
        world.cell_board[1][1].should be_alive
      end
    end

    context 'Rule #2: Any live cell with two or three live neighbours lives on to the next generation.' do
      it 'Should keep alive cell with 2 neighbours to next generation' do
        game = Game.new(world, [[0, 1], [1, 1], [2, 1]])
        world.live_neighbours_around_cell(world.cell_board[1][1]).count.should == 2
        game.tick!
        world.cell_board[0][1].should be_dead
        world.cell_board[1][1].should be_alive
        world.cell_board[2][1].should be_dead
      end

      it 'Should keep alive cell with 3 neighbours to next generation' do
        game = Game.new(world, [[0, 1], [1, 1], [2, 1], [2, 2]])
        world.live_neighbours_around_cell(world.cell_board[1][1]).count.should == 3
        game.tick!
        world.cell_board[0][1].should be_dead
        world.cell_board[1][1].should be_alive
        world.cell_board[2][1].should be_alive
        world.cell_board[2][2].should be_alive
      end
    end

    context 'Rule #3: Any live cell with more than three live neighbours dies, as if by overcrowding.' do
      it 'Should kill live cell with more than 3 live neighbours' do
        game = Game.new(world, [[0, 1], [1, 1], [2, 1], [2, 2], [1, 2]])
        world.live_neighbours_around_cell(world.cell_board[1][1]).count.should == 4
        game.tick!
        world.cell_board[0][1].should be_alive
        world.cell_board[1][1].should be_dead
        world.cell_board[2][1].should be_alive
        world.cell_board[2][2].should be_alive
        world.cell_board[1][2].should be_dead
      end
    end

    context 'Rule #4: Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.' do
      it 'Revives dead cell with 3 neighbours' do
        game = Game.new(world, [[0, 1], [1, 1], [2, 1]])
        world.live_neighbours_around_cell(world.cell_board[1][0]).count.should == 3
        game.tick!
        world.cell_board[1][0].should be_alive
        world.cell_board[1][2].should be_alive
      end
    end

  end

  context 'Game of life window' do
    subject { window }

    it 'Responds to proper methods' do
      subject.should respond_to(:height)
      subject.should respond_to(:width)
    end
  end

end