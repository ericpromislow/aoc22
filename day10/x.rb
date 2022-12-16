class Processor
  attr_reader :strengths
  def initialize
    @cycle = 1
    @total = 1
    @strengths = []
  end
  def noop
    strengthCheck
    @cycle += 1
    where
  end
  def addx(val)
    strengthCheck
    @cycle += 1
    strengthCheck
    @cycle += 1
    @total += val
    where
  end
  def strength
    @strengths.sum
  end

  private

  def where
    #puts "cycle: #{@cycle}, total:#{@total}"
  end
  def strengthCheck
    if @cycle % 40 == 20
      @strengths << @cycle * @total
    end
  end
end

cpu = Processor.new
ARGF.readlines.each_with_index do |line, i|
  line.chomp!
  #puts line
  if line == 'noop'
    cpu.noop
  else
    m = /^addx\s+(-?\d+)\s*$/.match(line)
    abort("Failed to handle line #{i}:#{line}") if !m
    cpu.addx(m[1].to_i)
  end
end
puts cpu.strength
