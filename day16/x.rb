class NodesList
  attr_reader :nodes
  def initialize
    @nodes = {}
  end
  def intern(node)
    @nodes[node.name] = node
  end
end

class ChildrenForNode
  attr_accessor :shadows
  def initialize(nodesList)
    @nodesList = nodesList
    @shadows = {}
  end
  def get_children(node)
    if !shadows.has_key?(node.name)
      shadows[node.name] = node.children.map {|name| @nodesList.nodes[name] }
    end
    shadows[node.name]
  end
end

class Node
  attr_reader :gain, :children, :name, :nodeChildren
  attr_accessor :childNodes, :visited, :considering
  def initialize(name, children, gain)
    @visited = false
    @considering = false
    @name = name
    @children = children
    @gain = gain
  end

  def to_s
    "<Node #{name}, children: #{children}, gain: #{gain}"
  end

  def bestChoice(timeLeft)
    childNodes = $nodeTable.get_children(self)
    puts "Getting best choice for #{name}"
    freeNodes = childNodes.reject {|node| node.visited || node.considering } # (&:visited)
    retPacket = ['', 0, 0, 0]
    if timeLeft <= 1
      return ['', 0, 0, 0]
    elsif timeLeft == 2
      return ['', 2, gain, 1]
    end
    if freeNodes.size == 0
      return [name, 1, gain * (timeLeft - 1), 1]
    end
    maxPayback = -1
    freeNodes.each do |childNode|
      childNode.considering = true
      _, costThere, rawPayback, costBack = childNode.bestChoice(timeLeft - 1)
      payback = rawPayback
      if maxPayback < payback
        retPacket = [childNode.name, costThere + 1, payback * (timeLeft - 2), costBack + 1]
      end
      childNode.considering = false
    end
    return retPacket
  end
end


nodeList = NodesList.new
$nodeTable = ChildrenForNode.new(nodeList)

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
startNode.considering = true
childChoice = startNode.bestChoice(30)
puts childChoice
