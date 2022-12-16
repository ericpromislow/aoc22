class Square
  attr_accessor :visited, :shortestPathFromHere, :bestPath
  attr_reader :orig, :elevation
  def initialize(c)
    @visited = 0
    @orig = c
    @elevation = convert(c)
    @shortestPathFromHere = nil
    @bestPath = []
  end

  private
  def convert(s)
    case s
    when 'S'
      return 1
    when 'E'
      return 26
    when /[a-z]/
      return s.ord - 'a'.ord + 1
    else
      abort("Can't convert value #{s}")
    end
  end
end

class Grid
  attr_reader :rows
  def initialize
    @rows = []
  end
  def parseInput
    ARGF.each do |line|
      @rows << line.chomp.split('').map {|s| Square.new(s) }
    end
    @longestPossiblePath = @rows.size * (@rows[0] || []).size
  end

  def findShortestPath(square, row, col)
    if square.shortestPathFromHere
      return square.bestPath
#      return square.shortestPathFromHere
    end
    if square.orig == 'E'
      square.shortestPathFromHere = 0
      return [[row, col]]
#      return 0
    end
    nbrs = getNonVisitedNeighbors(square, row, col)
    if nbrs.size == 0
      # No path available
      puts "No path available at [#{row}, #{col}], #{ square.elevation }"
      return nil
    end
    candidateLength = @longestPossiblePath + 1
    #    currentPath = []
    min_nbr = nil
    nbrs.each do |nbr|
      newSquare = nbr[:square]
      newSquare.visited = 1
      newPath = findShortestPath(newSquare, nbr[:row], nbr[:col])
      newSquare.visited = 0
      if newPath.nil?
#        puts "Eliminate going from [#{row}, #{col}] to [#{nbr[:row]}, #{ nbr[:col] }]"
      else
        if candidateLength >= newPath.size
          min_nbr = nbr
#          puts "At square row #{row}, col #{col}, elevation #{square.elevation}, looking at new square #{ nbr[:row] }, #{nbr[:col]}, elevation #{newSquare.elevation}, len: #{ newPath.size }"
          candidateLength = newPath.size
        end
      end
    end
    if min_nbr.nil?
#      puts "Didn't find a path from #{row}, col #{col}, elevation #{square.elevation}"
      return nil
    end
#   puts "At square row #{row}, col #{col}, elevation #{square.elevation}, finally go with square #{ min_nbr[:row] }, #{min_nbr[:col]}, elevation #{min_nbr[:square].elevation}, len: #{ min_nbr[:square].bestPath.size }"
    square.bestPath = [[row, col]] + min_nbr[:square].bestPath
    return square.bestPath
#    end
  end

  def getNonVisitedNeighbors(square, row, col)
    nbrs = []
    [[row - 1, col],
     [row + 1, col],
     [row, col - 1],
     [row, col + 1]].each do |r, c|
      if r >= 0 && r < @rows.size
        if c >= 0 && c < @rows[r].size
          newSquare = @rows[r][c]
          if newSquare.visited == 0 && newSquare.elevation <= square.elevation + 1
            nbrs << {row: r, col: c, square: newSquare}
          end
        end
      end
    end
    return nbrs
  end

end

g = Grid.new
g.parseInput

r = c = -1
square = nil
g.rows.each_with_index do |row, rowIndex|
  col = row.find_index { |square| square.orig == 'S' }
  if col
    r = rowIndex
    c = col
    square = row[c]
    break
  end
end

require 'pp'
#PP.pp g

square.visited = 1
path = g.findShortestPath(square, r, c)
PP.pp path

puts path.size
