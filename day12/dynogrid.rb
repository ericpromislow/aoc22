$numScoreSets = 0

class Square
  attr_accessor :score, :visited
  attr_reader :orig, :elevation
  def initialize(c)
    @visited = false
    @orig = c
    @elevation = convert(c)
    @score = nil
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

  def findSquare(letter)
    r = c = -1
    square = nil
    @rows.each_with_index do |row, rowIndex|
      col = row.find_index { |square| square.orig == letter }
      if col
        r = rowIndex
        c = col
        square = row[c]
        return [rowIndex, col, square]
      end
    end
    return nil
  end

  def evaluateScores(square, row, col, score)
    square.score = score
    square.visited = true
    $numScoreSets += 1
    nbrs = getNonVisitedNeighbors(square, row, col)
    if nbrs.size == 0
      return
    end
    nbrs.each do |nbr|
      newSquare = nbr[:square]
      evaluateScores(newSquare, nbr[:row], nbr[:col], score + 1)
    end
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
          if (newSquare.elevation >= square.elevation - 1 && 
             (!newSquare.visited || newSquare.score > square.score + 1))
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

r, c, square = g.findSquare('E')

path = g.evaluateScores(square, r, c, 0)

r, c, square = g.findSquare('S')
puts "Path from S: #{ square.score }"
s_score = square.score
a_squares = g.rows.map do |row|
  row.find_all { |square| square.orig == 'a' }
end
a_square = a_squares.flatten.reject{|sq| sq.score.nil? }.sort{|a, b| a.score <=> b.score}[0].score

puts "Shortest Path from S or an 'a': #{ [s_score, a_square].min }"

puts "$numScoreSets:  #{ $numScoreSets }"
