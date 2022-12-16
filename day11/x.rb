require './monkey'


monkeySet = MonkeySet.new
monkeySet.parseInput
monkeys = monkeySet.monkeys

10000.times do |i|
  monkeys.each { |monkey| monkey.turn(monkeys, monkeySet.limit) }
end

sorted = monkeySet.sortedByActivity[0..2]
activity = sorted[0].numItemsInspected * sorted[1].numItemsInspected

puts activity


