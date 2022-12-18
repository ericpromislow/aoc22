# Use floyd-warshaw to reduce 

MaxTime = 30

class NodesList
  attr_reader :nodes, :costs, :distances
  def initialize
    @nodes = {}
    @distances = {}
  end
  def intern(node)
    @nodes[node.name] = node
    node.children.each do |child|
      updateDistance(node.name, child)
    end
  end
  def updateDistance(parent, child)
    if !@distances.has_key?(parent)
      @distances[parent] = {parent => 0}
    end
    @distances[parent][child] = 1
  end
  def buildCostGraph(headNode, nodeNamesToIgnore=[])
    abort("Need to figure out what to do with a gainful head node") if headNode.gain > 0
    
    @costs = {}
    keys = @nodes.keys
    keys.each do |k1|
      d = distances[k1]
      keys.each do |k2|
        if !d.has_key?(k2)
          distances[k1][k2] = MaxTime
        end
      end
    end

    keys.each do |kk|
      keys.each do |ki|
        keys.each do |kj|
          if distances[ki][kj] > distances[ki][kk] + distances[kk][kj] 
            distances[ki][kj] = distances[ki][kk] + distances[kk][kj]
          end
        end
      end
    end

    # Now build the cost graph, distance between each pair of nodes we
    # care about, + 1 for the time needed to open the value.

    # Now delete all the zero-gain nodes except for the headNode
    gainfulNodes, gainlessNodes = @nodes.values.partition {|n| n.gain > 0 && !nodeNamesToIgnore.include?(n.name) }
    gainfulNodeNames = gainfulNodes.map(&:name)
    gainlessNodeNames = gainlessNodes.map(&:name)

    (gainfulNodes + [headNode]).each do |posNode|
      posName = posNode.name
      @costs[posName] = {}
      cost = @costs[posName]
      d = distances[posName]
      newChildren = gainfulNodeNames - [posName]
      posNode.children = newChildren
      newChildren.each do |newChild|
        if !d.has_key?(newChild)
          abort("no dist for #{posName} to #{newChild}")
        end
        cost[newChild] = d[newChild] + 1
      end
    end
    headName = headNode.name
    gainlessNodeNames.each do |name|
      next if name == headName
      @nodes.delete(name)
    end
  end

  def evaluate(node, timeLeft, childrenLeft)
    @numChecks = 0
    maxGain = evaluateAux(node, timeLeft, childrenLeft)
#    puts "numChecks needed: #{@numChecks}"
    return maxGain
  end

  def evaluateAux(node, timeLeft, childrenLeft)
    @numChecks += 1
#    puts ">>> evaluate node: #{node.name}, timeLeft:#{timeLeft}..."
    cost = costs[node.name]
    thisGain = timeLeft * node.gain
    validChildren = childrenLeft.filter {|childName| timeLeft > cost[childName]}
    maxChildGain = 0
    # Don't bother sorting yet
    validChildren.each_with_index do |childName, index|
      childNode = nodes[childName]
      childGain = evaluateAux(childNode, timeLeft - cost[childName], validChildren[0...index] + validChildren[index+1..-1])
      if maxChildGain < childGain
        maxChildGain = childGain
      end
    end
#    puts "evaluate: node: #{node.name}, timeLeft:#{timeLeft}, => gain #{thisGain + maxChildGain}"
    return thisGain + maxChildGain
  end
end

class Node
  attr_reader :gain, :name
  attr_accessor :children
  def initialize(name, children, gain)
    @name = name
    @children = children
    @gain = gain
  end

  def to_s
    "<Node #{name}, children: #{children}, gain: #{gain}"
  end

  def clone
    return self.class.new(name, children.dup, gain)
  end
end



nodes = []

i = 1
ARGF.each do |line|
  m = /^Valve (.*?) has flow rate=(\d+); tunnels? leads? to valves?\s+([A-Z, ]+)/.match(line)
  abort("Can't parse line #{i}: #{line}") if !m
  node = Node.new(m[1], m[3].strip.split(/,\s*/), m[2].to_i)
  nodes << node
  i += 1
end

gainfulNodes, gainlessNodes = nodes.partition {|node| node.gain > 0}
gainfulNodeNames = gainfulNodes.map(&:name)

maxPartitionedScore = 0
done = {}
startPoint = gainfulNodeNames.size / 3
endPoint = gainfulNodeNames.size / 2

origStartNode = nodes.find{|n| n.name == 'AA'}

iter = 0

puts "gainfulNodeNames: #{gainfulNodeNames}"
puts "gainless: #{gainlessNodes.map(&:name)}"

# numIters = 0
# (startPoint .. endPoint).to_a.each do |size|
#   gainfulNodeNames.combination(size).each do | player1Names |
#     player2Names = gainfulNodeNames - player1Names
#     if (player1Names <=> player2Names) < 0
#       numIters += 1
#     end
#   end
# end
# puts "Expected num iters to process: #{numIters}"

(startPoint .. endPoint).to_a.each do |size|
  gainfulNodeNames.combination(size).each do | player1Names |
    player2Names = gainfulNodeNames - player1Names

    if (player1Names <=> player2Names) > 0
      puts "Already saw permation 1:#{player1Names}, 2: #{player2Names}"
      next
    end
    
    puts "iter #{iter}: Graph for partition 1:#{player1Names}, partition 2:#{player2Names}"
    
    iter += 1

    nodeList1 = NodesList.new
    nodeList2 = NodesList.new

    nodes.each do |node|
      nodeList1.intern(node.clone)
      nodeList2.intern(node.clone)
    end
    startNode1 = origStartNode.clone
    startNode2 = origStartNode.clone
    
    nodeList1.buildCostGraph(startNode1, player2Names)
    nodeList2.buildCostGraph(startNode2, player1Names)

#    puts "Graph for partition 1:#{player1Names}"
#    pp nodeList1.nodes.map(&:to_s)
#    puts "Costs:"
#    pp nodeList1.costs
#    puts "Graphs for partition 2:#{player2Names}"
#    pp nodeList2.nodes.map(&:to_s)
#    pp nodeList2.costs

    maxScore1 = nodeList1.evaluate(startNode1, 26, player1Names)
    maxScore2 = nodeList2.evaluate(startNode2, 26, player2Names)
    puts "iter: #{iter}: maxScore1: #{maxScore1}, maxScore2: #{maxScore2} => #{maxScore1 + maxScore2}"
    if maxPartitionedScore < maxScore1 + maxScore2
      maxPartitionedScore = maxScore1 + maxScore2
      puts "Set max score to #{maxPartitionedScore} for partitions <<#{player1Names}>> and  <<#{player2Names}>>"
    elsif maxPartitionedScore == maxScore1 + maxScore2
      puts "Found another max score of #{maxPartitionedScore} for partitions <<#{player1Names}>> and  <<#{player2Names}>>"
    end

  end
end

puts "result: #{maxPartitionedScore}"
