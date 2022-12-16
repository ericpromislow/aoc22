class Processor
  attr_reader :grid
  NumRows = 6
  RowLen = 40
  def initialize
    @position = 0
    @total = 1
    @grid = Array.new(NumRows).map{ ' ' * RowLen }
  end
  def noop
    draw
    @position += 1
  end
  def addx(val)
    draw
    @position += 1
    draw
    @position += 1
    @total += val
  end

  private

  def draw
    row = @position / RowLen
    col = @position % RowLen
    if [@total - 1, @total, @total + 1].include?(col)
      @grid[row][col] = '#'
    else
      @grid[row][col] = '.'
    end
  end
end

cpu = Processor.new
ARGF.readlines.each_with_index do |line, i|
  line.chomp!
  if line == 'noop'
    cpu.noop
  else
    m = /^addx\s+(-?\d+)\s*$/.match(line)
    abort("Failed to handle line #{i}:#{line}") if !m
    cpu.addx(m[1].to_i)
  end
end
puts
puts cpu.grid
