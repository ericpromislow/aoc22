class ASTNumber
  attr_reader :value
  def initialize(value)
    @value = value
  end
  def compare(other)
    if other.class == ASTList
      return ASTList.new([self]).compare(other)
    else
      return @value <=> other.value
    end
  end
end

class ASTList
  attr_reader :children
  def initialize(children)
    @children = children
  end
  def compare(other)
    if other.class == ASTNumber
      return compare(ASTList.new([other]))
    else
      otherKids = other.children
      self.children.each_with_index do |child, index|
        if index >= otherKids.size
          return +1
        else
          val = child.compare(otherKids[index])
          if val != 0
            return val
          end
        end
      end
      return self.children.size == otherKids.size ? 0 : -1
    end
  end
end

class Token
  attr_reader :tokenType, :value, :pos
  def initialize(tokenType, value, pos)
    @tokenType = tokenType
    @value = value
    @pos = pos
  end
end

class AST
  def parseLine(line)
    @origLine = line
    tokens = []
    line.scan(/(\[)|(\])|(\d+)|(,)/) do |matches|
      idx = matches.find_index{|x| !x.nil?}
      tokens.push(Token.new(idx, matches[idx], $`.size))
    end
    if tokens[0].tokenType != 0
      doError("expecting a list to start with a [", tok)
    end
    tree = parse(tokens)
    if tokens.size > 0
      doError("have tokens left to parse, remaining token:", tok)
    end
    return tree
  end

  def doError(exp, tok)
    pos = tok.pos
    abort("expecting #{ exp }, got #{ tok.tokenType }/#{ tok.value } in #{@origLine[0...pos]}<--here-->#{@origLine[pos..-1]}")
  end

  def parse(tokens)
    tok = tokens.shift
    if tok.nil?
      abort("ran out of tokens too early")
    end
    if tok.tokenType == 0
      node = ASTList.new(parseChildren(tokens))
    elsif tok.tokenType == 2
      return ASTNumber.new(tok.value.to_i)
    else
      doError("a value or list", tok)
    end
  end

  # First token is either a value, followed by {, num} or ]
  # or a ']' -- leave with an empty list
  def parseChildren(tokens)
    list = []

    if tokens.size == 0
      abort("ran out of tokens too early: expected ] or a val")
    end
    # Empty list
    if tokens[0].tokenType == 1
      tokens.shift
      return list
    end
    
    while true
      list << parse(tokens)
      tok = tokens.shift
      if tok.nil?
        abort("ran out of tokens too early: expected ] or a ,")
      end
      if tok.tokenType == 1
        return list
      elsif tok.tokenType != 3
        doError("a ] or comma in a list", tok)
      end
    end
  end
end

require 'pp'

class Array
  def compare(other)
    if other.class == Integer
      return self.compare([other])
    else
      self.each_with_index do |child, index|
        if index >= other.size
          return +1
        else
          val = child.compare(other[index])
          if val != 0
            return val
          end
        end
      end
      return self.size == other.size ? 0 : -1
    end
  end
end

class Integer
  def compare(other)
    if other.class == Array
      return [self].compare(other)
    else
      return self <=> other
    end
  end
end

class Packet
  attr_reader :line, :tree
  def initialize(line, tree)
    @line = line
    @tree = tree
  end
end

ast = AST.new
packets = []
begin
  while true
    line = ARGF.readline.chomp
    if line != ''
      tree = eval(line)
      packets.push(Packet.new(line, tree))
    end
  end
rescue EOFError
  puts "Total: #{ packets.size }"
end

line = '[[2]]'
tree = eval(line)
packets.push(Packet.new(line, tree))
line = '[[6]]'
tree = eval(line)
packets.push(Packet.new(line, tree))

puts "Before sorting..."
packets.sort! { |a, b|
  a.tree.compare(b.tree)
}
puts "After sorting..."
idx1 = packets.find_index {|p| p.line == '[[2]]' }
idx2 = packets.find_index {|p| p.line == '[[6]]' }
puts (idx1 + 1) * (idx2 + 1)
