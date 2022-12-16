class DaVoid < Exception
end

class Grid
  attr_reader :grid
  def initialize
    @grid = {}
    @maxRow = -1
  end

  def parseInput
    ARGF.each do |line|
      line.chomp!
      parts = line.split(/\s+->\s+/).map{|p| p.split(',').map(&:to_i)}
      col, row = parts.shift
      expandGrid(row)
      grid[row][col] = '#'
      lastPoint = [col, row]      
      parts.each do |col, row|
        col0, row0 = lastPoint
        if col == col0
          r = makeRange(row0, row)
          r.to_a.each do |row1|
            expandGrid(row1)
            grid[row1][col] = '#'
          end
        elsif row == row0
          # No need to expand the grid, we're on the same row
          r = makeRange(col0, col)
          r.to_a.each do |col1|
            grid[row][col1] = '#'
          end
        else
          abort("Can't draw from lastPoint #{lastPoint} to current point #{[col, row]}")
        end
        lastPoint = [col, row]
      end
    end
  end

  # return the coordinate where it lands,
  # or [row, nil] if it hit the bottom
  def dropSand(row, col)
    nextRow = row + 1
    if nextRow > @maxRow
      return [nextRow, nil]
    elsif !@grid[nextRow] || !@grid[nextRow][col]
      # Just keep going
      return dropSand(nextRow, col)
    elsif @grid[nextRow][col - 1]
      if @grid[nextRow][col + 1]
        # Stays at the current point
        expandGrid(row)
        @grid[row][col] = 'o'
        return [row, col]
      else
        # Fall to the right
        return dropSand(nextRow, col + 1)
      end
    else
      # If both the left and right are unblocked, fall to the left
      return dropSand(nextRow, col - 1)
    end
  end

  def makeRange(a, b)
    a1, b1 = [a, b].sort
    return (a1..b1).to_a
  end

  def expandGrid(row)
    if !@grid[row]
      @grid[row] = {}
      if @maxRow < row
        @maxRow = row
      end
    end
  end

  def xLimits
    minIndex = maxIndex = @grid.values[0].keys[0]
    (@maxRow + 1).times do |row|
      if grid[row]
        keys = grid[row].keys.sort.uniq
        if minIndex > keys[0]
          minIndex = keys[0]
        end
        if maxIndex < keys[-1]
          maxIndex = keys[-1]
        end
      end
    end
    puts "xLimits => #{[minIndex, maxIndex]}"
    return [minIndex, maxIndex]
  end
    

  def drawGrid
    xMin, xMax = xLimits
    puts "#{xMin} ... #{xMax}"
    (@maxRow + 1).times do |row|
      print "#{row}: "
      if !grid[row]
        puts "... ..."
      else
        lastCol = xMin - 1
        grid[row].entries.sort.each do |col, val|
          while lastCol < col - 1
            print "."
            lastCol += 1
          end
          print val
          lastCol = col
        end
        puts ""
      end
    end
  end
        
end

g = Grid.new
g.parseInput


require 'pp'
PP.pp g.grid

g.drawGrid

iter = 1
while true
  row, col = g.dropSand(0, 500)
  if col.nil?
    puts "Done at row #{row}"
    break
  end
  puts "iter: #{iter}"
  iter += 1
#  PP.pp g.grid
  g.drawGrid
end

puts iter
        
