class NodesList
  attr_reader :nodes
  def initialize
    @nodes = {}
  end
  def intern(node)
    @nodes[node.name] = node
  end
end

class Item
  attr_accessor :timeLeft, :nodeName, :state, :score, :fromNodeName
  def initialize(timeLeft, nodeName, state, score, fromNodeName)
    @timeLeft = timeLeft
    @nodeName = nodeName
    @state = state # hash of opened node names
    @score = score
    @fromNodeName = fromNodeName
  end

  def to_s
    "<Item T:#{timeLeft}, #{nodeName} score:#{score}, calledFrom:#{fromNodeName}>"
  end
    
end

class Node
  attr_reader :gain, :children, :name, :nodeChildren
  attr_accessor :childNodes, :visited, :considering
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
#pp nodeList.nodes.map(&:to_s)

startNode = nodeList.nodes['AA']
$nodeList = nodeList

def nodeIsDone(nodeName, state, fromNodeNames)
  if fromNodeNames.include?(nodeName)
    # Found a circular list
    return false
  end
  node = $nodeList.nodes[nodeName]
  children = node.children - [nodeName]
  if children.size == 0 && (node.gain == 0 || state.has_key?(nodeName))
    return 0
  end
  children.each do |childName|
    child = $nodeList.nodes[childName]
    if !nodeIsDone(childName, state, fromNodeNames + [nodeName])
      return false
    end
  end
  return true
end

def stateKey(timeStamp, nodeName, state)
  return "T:#{timeStamp}, N:#{nodeName}, V:#{state.sort.map{|e| e.join(":")}.join(",")}"
end  

deque = [Item.new(30, "AA", {}, 0, nil)]
dp = {} # Map <time><sorted-node-name><score> => <total-score>
numberNodesProcessed = 0
maxScore = 0
while deque.size > 0
  item = deque.shift
  numberNodesProcessed += 1
  puts item.to_s
  if maxScore < item.score
    maxScore = item.score
  end
  timeLeft = item.timeLeft
  if timeLeft <= 2
    # No point pushing children that won't have any effect (1 to move, 1 to open)
    next
  end
  nodeName = item.nodeName
  skey = stateKey(timeLeft, nodeName, item.state)

  if dp.has_key?(skey)
    next
  else
    dp[skey] = item.score
  end

  node = nodeList.nodes[nodeName]
  children = node.children # Also names
  
  if !item.state.has_key?(nodeName) && node.gain > 0
    newState = item.state.clone
    newState[nodeName] = timeLeft - 1
    newScore = node.gain * (timeLeft - 1) + item.score
    node.children.each do |childName|
      deque.push(Item.new(timeLeft - 2, childName, newState, newScore, nodeName))
    end
  end

  # And go to other nodes without doing anything here.
  node.children.each do |childName|
    next if childName == item.fromNodeName
    deque.push(Item.new(timeLeft - 1, childName, item.state, item.score, nodeName))
  end
end

puts "maxScore: #{maxScore}"
puts "numberNodesProcessed: #{numberNodesProcessed}"
