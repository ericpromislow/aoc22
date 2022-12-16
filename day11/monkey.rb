class Monkey
  attr_accessor :true_monkey, :false_monkey
  attr_accessor :testFactor
  attr_reader :num, :numItemsInspected
  def initialize(num)
    @num = num
    @numItemsInspected = 0
  end

  def to_s
    return "<Monkey items:num:#{@num}, [#{@items.join(', ')}], op:#{@operation}, testFactor:#{testFactor}, numItemsInspected:#{numItemsInspected}, trueMonk:#{true_monkey.num}, falseMonk:#{false_monkey.num}>"
  end
  
  def update(items, operation, test)
    @items = items
  end

  def transfer(item)
    @items << item
  end

  def startingItems=(items)
    @items = items
  end

  def setOp(op, oldVarName)
    if ! /((?:old)|[-+*\/ ]+)+/.match(op)
      abort("Bad chars i op: #{ op }")
    end
    @operation = op.gsub(oldVarName, 'worryLevel')
  end

  def turn(monkeys, limit)
    @numItemsInspected += @items.size
    @items.each do |worryLevel|
      newWorryLevel = eval(@operation) % limit
      if newWorryLevel % testFactor == 0
        true_monkey.transfer(newWorryLevel)
      else
        false_monkey.transfer(newWorryLevel)
      end
    end
    @items.clear
  end
end

class MonkeySet
  attr_reader :monkeys, :limit
  def initialize
    @monkeys = []
    @limit = 1
  end

  def guaranteeMonkeys(i)
    while monkeys.size <= i
      @monkeys << Monkey.new(monkeys.size)
    end
  end

  def sortedByActivity
    return @monkeys.sort{|a, b| b.numItemsInspected <=> a.numItemsInspected }
  end

  def parseInput()
    currentMonkeyNum = -1
    lineNo = 0
    while true
      while true
        line = ARGF.readline.chomp
        lineNo += 1
        break unless line =~ /^\s*$/
      end
      m = /^Monkey\s+(\d+)/.match(line)
      abort("Not seeing a monkey # at line #{lineNo} in #{line}") if !m
      guaranteeMonkeys(currentMonkeyNum = m[1].to_i)
      currentMonkey = monkeys[currentMonkeyNum]
      
      line = ARGF.readline.chomp
      lineNo += 1
      m = /^\s+Starting items: ([0-9,\s]+)\s*$/.match(line)
      abort("Not seeing starting items # at line #{lineNo} in #{line}") if !m
      currentMonkey.startingItems = m[1].split(/,\s*/).map(&:to_i)
      
      line = ARGF.readline.chomp
      lineNo += 1
      m = /^\s+Operation:\s+new\s+=\s+(.*)/.match(line)
      abort("Not seeing op line #{lineNo} in #{line}") if !m
      currentMonkey.setOp(m[1], 'old')
      
      line = ARGF.readline.chomp
      lineNo += 1
      m = /^\s+Test:\s+divisible\s+by\s+(\d+)/.match(line)
      abort("Not seeing divisibe test at line #{lineNo} in #{line}") if !m
      factor = m[1].to_i
      currentMonkey.testFactor = factor
      if @limit % factor != 0
        @limit *= factor
      end
      
      line = ARGF.readline.chomp
      lineNo += 1
      m = /^\s+If true:\s+throw\s+to\s+monkey\s+(\d+)/.match(line)
      abort("Not seeing monkey at line #{lineNo} in #{line}") if !m
      monk = m[1].to_i
      guaranteeMonkeys(monk)
      currentMonkey.true_monkey = @monkeys[monk]
      
      line = ARGF.readline.chomp
      lineNo += 1
      m = /^\s+If false:\s+throw\s+to\s+monkey\s+(\d+)/.match(line)
      abort("Not seeing monkey at line #{lineNo} in #{line}") if !m
      monk = m[1].to_i
      guaranteeMonkeys(monk)
      currentMonkey.false_monkey = @monkeys[monk]
    end
  rescue EOFError
  end
end
