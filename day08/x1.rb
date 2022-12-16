class Forest
  def initialize
    @grid = []
  end
  def loadData
    ARGF.readlines.each do |line|
      line.chomp!
      @grid << line.split('').map(&:to_i)
    end
    @gridHeight = @grid.size
    @gridWidth = @grid[0].size
  end
  def numVisibleTrees
    # The outer trees are all visible
    numVisible = 0
    @grid.each_with_index do |row, y|
      row.each_with_index do |height, x|
        if isVisible(height, y, x)
          numVisible += 1
        end
      end
    end
    numVisible
  end

  def maxNumViewableTrees
    # The number of trees seen from each entry
    numVisible = 0
    @grid.each_with_index do |row, y|
      row.each_with_index do |height, x|
        scenicScore = getScenicScore(height, y, x)
        if numVisible < scenicScore
          numVisible = scenicScore
          @maxScenicPt = {row: y, col: x}
        end
      end
    end
    numVisible
  end

  def getScenicScore(height, rowNum, colNum)
    if rowNum == 0 || rowNum == @gridHeight - 1
      return 0
    end
    if colNum == 0 || colNum == @gridWidth - 1
      return 0
    end
    slice = @grid[rowNum]
    scores = numVisibleInSlice(height, slice, colNum)
    slice = @grid.map {|g| g[colNum] }
    scores += numVisibleInSlice(height, slice, rowNum)
    scores.reduce(1, &:*)
  end

  private

  def numVisibleInSlice(height, slice, colNum)
    [numVisibleInSubslice(height, slice[0...colNum].reverse),
     numVisibleInSubslice(height, slice[colNum + 1..-1])]
  end

  def numVisibleInSubslice(height, slice)
    n = slice.find_index{|h| h >= height}
    if !n
      return slice.size
    else
      return n + 1
    end
  end    

  def isVisible(height, rowNum, colNum)
    if rowNum == 0 || rowNum == @gridHeight - 1
      return true
    end
    if colNum == 0 || colNum == @gridWidth - 1
      return true
    end
    slice = @grid[rowNum]
    if isVisibleInSlice(height, slice, colNum)
      return true
    end
    slice = @grid.map {|g| g[colNum] }
    if isVisibleInSlice(height, slice, rowNum)
      return true
    end
    return false
  end

  def isVisibleInSlice(height, slice, idx)
    if slice[0...idx].all?{|h| h < height}
      return true
    end
    if slice[idx + 1..-1].all?{|h| h < height}
      return true
    end
    return false
  end
    
end

forest = Forest.new
forest.loadData
puts "Stop here"
puts forest.numVisibleTrees
puts forest.maxNumViewableTrees
    
                    
