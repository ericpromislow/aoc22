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
  def buildCostGraph(headNode)
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
    gainfulNodes, gainlessNodes = @nodes.values.partition {|n| n.gain > 0}
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
    puts "numChecks needed: #{@numChecks}"
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
end


nodeList = NodesList.new

i = 1
ARGF.each do |line|
  m = /^Valve (.*?) has flow rate=(\d+); tunnels? leads? to valves?\s+([A-Z, ]+)/.match(line)
  abort("Can't parse line #{i}: #{line}") if !m
  node = Node.new(m[1], m[3].strip.split(/,\s*/), m[2].to_i)
  nodeList.intern(node)
  i += 1
end

require 'PP'
pp nodeList.nodes.map(&:to_s)

startNode = nodeList.nodes['AA']
$nodeList = nodeList

nodeList.buildCostGraph(startNode)
puts "After collapse:"
puts "Graph:"
pp nodeList.nodes.map(&:to_s)
puts "Costs:"

result = nodeList.evaluate(startNode, 30, startNode.children)
puts "result: #{result}"
