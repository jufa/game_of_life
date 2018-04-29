
class ConwayWorld
  CELL = '⬡'
  NEW_CELL = '*'
  EMPTY = ' '

  HIDE_CURSOR = "\033[?25l"
  SHOW_CURSOR = "\033[?25h"
  WHITE_CURSOR = "\033[37m"
  MAGENTA_CURSOR = "\033[35m"
  GREEN_CURSOR = "\033[32m"

  def initialize(width: 5, height: 6, fill_ratio: 0.3, pattern: nil)
    if pattern
      @world = pattern
      @rows = world.size
      @columns = world.first.size
    else
      @columns = width
      @rows = height
      @world = Array.new(@rows) { Array.new(@columns) }
      fill(fill_ratio)
    end
  end

  def print_world(world: @world, title: 'no title', overwriteable_last: true)
    if overwriteable_last
      if defined? @not_first_print
         # cursor up to overwrite
        print "\033[#{@rows + 6}A"
      else
        @not_first_print = true
      end
    end

    print HIDE_CURSOR + WHITE_CURSOR + '-' * @columns + "\n#{title}\n" + '-' * @columns + "\n"
    world.each do |row|
      row.each do |cell|
        print cell == CELL ? MAGENTA_CURSOR : GREEN_CURSOR
        print cell == EMPTY ? EMPTY : CELL
      end
      print "\n"
    end
    print WHITE_CURSOR + '-' * @columns + "\n\n\n" + SHOW_CURSOR
  end

  def next_generation
    next_world =
    @world.map.with_index do |row, r|
      row.map.with_index do |cell, c|
        n = neighbour_count(r, c)
        if [CELL, NEW_CELL].include? @world[r][c]
          # any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
          # any live cell with two or three live neighbours lives on to the next generation.
          # any live cell with more than three live neighbours dies, as if by overpopulation.
          n == 2 || n == 3 ? CELL : EMPTY
        else
          # any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
          n == 3 ? NEW_CELL : EMPTY
        end
      end
    end

    # if just single period oscillators or no change, return false
    spot_check_stagnation = rand < 0.1
    return false if spot_check_stagnation && @last_world == next_world
    @last_world = @world
    @world = next_world
    true
  end

  private

  def fill(ratio)
    @world.map! do |row|
      row.map! do |cell|
       rand < ratio ? CELL : EMPTY
      end
    end
  end

  def neighbour_count(r, c)
    count = 0
    [-1, 0, 1].each do |dr|
      [-1, 0, 1].each do |dc|
        next if dr == 0 && dc == 0
        if c + dc < 0
          cpos = @columns - 1
        elsif c + dc >= @columns
          cpos = 0
        else
          cpos = c + dc
        end
        if r + dr < 0
          rpos = @rows - 1
        elsif r + dr >= @rows
          rpos = 0
        else
          rpos = r + dr
        end
        count = count + 1 if [CELL, NEW_CELL].include? @world[rpos][cpos]
      end
    end
    count
  end
end

class TerminalConway
  def initialize(width: 40, height: 20, fill_ratio: 0.5, rate: 0.02, pattern: nil)
    world = ConwayWorld.new width: width, height: height, fill_ratio: fill_ratio, pattern: pattern
    world.print_world(title: "Initial generation", overwriteable_last: false)

    generation = 0
    evolving = true

    while evolving do
      generation = generation + 1
      evolving = world.next_generation
      title = "Generation #{generation}"
      title << ": Evolution complete" unless evolving
      world.print_world(title: title)
      sleep(rate)
    end
  end
end

TerminalConway.new

