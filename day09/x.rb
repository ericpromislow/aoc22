RopeSize = 10

def makeRopeForDim(n)
  return (1..n).to_a.map{0}
end

class Grid
  SqrtTwo = 2.0 ** 0.5
  def initialize
    @rx = makeRopeForDim(RopeSize)
    @ry = makeRopeForDim(RopeSize)
    @visited = Hash.new(0)
    checkVisit
  end

  def closeEnough(idx)
    return (((@rx[idx] - @rx[idx - 1]) ** 2) + ((@ry[idx ] - @ry[idx - 1]) ** 2)) ** 0.5 <= SqrtTwo + 0.00001
  end    

  def move(line, i)
    puts line.chomp
    m = /^([LRUD])\s+(\d+)\s*$/.match(line)
    abort "Failed to process line #{i} <#{line}>" if !m
    case m[1]
    when 'L'
      goLeft m[2].to_i
    when 'R'
      goRight m[2].to_i
    when 'D'
      goDown m[2].to_i
    when 'U'
      goUp m[2].to_i
    end
  end

  def goLeft(num)
    goSideways(num, -1)
  end

  def goRight(num)
    goSideways(num, +1)
  end

  def goDown(num)
    goVertical(num, -1)
  end

  def goUp(num)
    goVertical(num, +1)
  end

  def goSideways(num, step)
    num.times do
      @rx[0] += step
      showWhere(0)
      sidewaysFollow(0, step)
      puts "sideways: Rope: #{@rx.zip(@ry)}"
    end
  end

  def sidewaysFollow(idx, step)
    while idx < @rx.size - 1
      nextIdx = idx + 1
      if !closeEnough(nextIdx)
        adjustPosition(idx, nextIdx)
        showWhere(nextIdx)
        checkVisit if nextIdx == @rx.size - 1
      else
        showWhere(nextIdx)
        break
      end
      idx += 1
    end
  end

  def goVertical(num, step)
    num.times do
      @ry[0] += step
      showWhere(0)
      verticalFollow(0, step)
      puts "vertical: Rope: #{@rx.zip(@ry)}"
    end
  end

  def verticalFollow(idx, step)
    while idx < @rx.size - 1
      nextIdx = idx + 1
      if !closeEnough(nextIdx)
        adjustPosition(idx, nextIdx)
        showWhere(nextIdx)
        checkVisit if nextIdx == @rx.size - 1
      else
        showWhere(nextIdx)
        break
      end
      idx += 1
    end
  end

  # The two knots are not close enough together
  def adjustPosition(idx, nextIdx)
    if (@rx[nextIdx] - @rx[idx]).abs >= 2 && (@ry[nextIdx] - @ry[idx]).abs >= 2
      # Move diagonal in that direction
      if @rx[nextIdx] <= @rx[idx]
        @rx[nextIdx] += 1
      else
        @rx[nextIdx] -= 1
      end
      if @ry[nextIdx] <= @ry[idx]
        @ry[nextIdx] += 1
      else
        @ry[nextIdx] -= 1
      end
      return
    end

    if @rx[nextIdx] - @rx[idx] >= 2
      @rx[nextIdx] = @rx[idx] + 1
      @ry[nextIdx] = @ry[idx]
    elsif @rx[nextIdx] - @rx[idx] <= -2
      @rx[nextIdx] = @rx[idx] - 1
      @ry[nextIdx] = @ry[idx]
    end
    if @ry[nextIdx] - @ry[idx] >= 2
      @ry[nextIdx] = @ry[idx] + 1
      @rx[nextIdx] = @rx[idx]
    elsif @ry[nextIdx] - @ry[idx] <= -2
      @ry[nextIdx] = @ry[idx] - 1
      @rx[nextIdx] = @rx[idx]
    end
  end

  def showWhere(idx)
    puts "idx #{idx}: now at #{@rx[idx]},#{@ry[idx]}"
  end

  def checkVisit
    idx = RopeSize - 1
    square = "#{@rx[idx]}:#{@ry[idx]}"
    puts "knot #{idx} visiting #{square}"
    if @visited[square] == 0
      puts "New visit for the rope end!"
    end
    @visited[square] += 1
  end

  def numTailPositions
    @visited.size
  end
end

grid = Grid.new

ARGF.readlines.each_with_index do |line, i|
  grid.move(line, i)
end

puts grid.numTailPositions
