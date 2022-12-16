class Point
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
  def to_s
    "<#{x}, #{y}>"
  end
end

class Reading
  attr_reader :sensor, :beacon, :distance
  def initialize(sensor, beacon)
    @sensor = sensor
    @beacon = beacon
    @distance = (sensor.x - beacon.x).abs + (sensor.y - beacon.y).abs
  end

  def range_from(target_y)
    dist_y = (sensor.y - target_y).abs
    dist_rest = @distance - dist_y
    if dist_rest < 0
#      puts "Can't get to #{target_y} from #{sensor}"
      return nil
    end
    x_min = sensor.x - dist_rest
    x_max = sensor.x + dist_rest

    # Watch out for a beacon on the target line
    if beacon.y == target_y
      if x_min == beacon.x
        x_min += 1
      end
      if x_max == beacon.x
        x_max -= 1
        if x_max < x_min
          puts "Ignore the only reachable point -- it's our beacon"
          return nil
        end
      end
    end

    return (x_min..x_max)
  end
end

class Readings
  attr_reader :readings
  def initialize
    @readings = []
  end
  def parseInput
    i = 1
    ARGF.each do |line|
      m = /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/.match(line)
      abort("Can't parse line #{i}: #{line}") if !m
      sensor = Point.new(m[1].to_i, m[2].to_i)
      beacon = Point.new(m[3].to_i, m[4].to_i)
      @readings << Reading.new(sensor, beacon)
      
      i += 1
      
    end
  end
  def hasBeacon(x, y)
    return readings.any? do |r|
      b = r.beacon
      b.x == x && b.y == y
    end
  end
end

def getRanges(r, target, minCoord, maxCoord)
  ranges = []
  r.readings.each do |reading|
#  puts "sensor at #{reading.sensor}, beacon at #{reading.beacon}, distance: #{reading.distance}"
    range = reading.range_from(target)
    if range
      r0 = range.first < minCoord ? minCoord : range.first
      r1 = range.last > maxCoord ? maxCoord : range.last
      if r0 != range.first || r1 != range.last
#        puts "Cutting range #{range} down to (#{r0} .. #{r1})"
        if r0 > r1
#          puts "Actually, ignoring it"
          next
        end
        range = (r0 .. r1)
      end
      ranges << range
    end
  end
  ranges
end

def collapseRanges(ranges)
  return ranges if ranges.size <= 1
  r2 = ranges.sort{|a, b|
    byFirst = a.first <=> b.first
    byFirst == 0 ? a.last <=> b.last : byFirst
  }
  r3 = [r2[0]]
  last_r = r2[0]
  r2[1..-1].each do |r|
    if r.first > last_r.last + 1
      r3 << r
    elsif r.last > last_r.last
      r3[-1] = (r3[-1].first .. r.last)
    else
      # this range is a subset of what we've seen, so do nothing
    end
    last_r = r3[-1]
  end
  return r3
end

r = Readings.new
r.parseInput

lim = 4000000

(lim + 1).times do |y|
#  puts "target: #{y}"
  ranges = getRanges(r, y, 0, lim)
#  puts "raw ranges: #{ranges}"
  cranges = collapseRanges(ranges)
#  puts "target #{y}, collapsed ranges: #{cranges}"

  if cranges.size == 2
    firstEnd = cranges[0].last
    nextStart = cranges[1].first
    if nextStart == firstEnd + 2
      puts "\nThere's a possible gap at x=#{firstEnd + 1}, y=#{y}"
      if !r.hasBeacon(firstEnd + 1, y)
        puts "!!! Yes"
      else
        puts "... nope, there's a beacon there."
      end
    end
  end

  if (y + 1) % 10000 == 0
    STDERR.print('.')
    if (y + 1) % (75 * 10000) == 0
      STDERR.print("\n")
    end
  end

  #puts "Num targeted: #{cranges.map(&:size).sum}"
end
