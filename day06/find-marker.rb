require 'set'

def findSignal(chars)
  i = 0
  while i < chars.size
    if Set.new(chars[i..i + 3]).size == 4
      return i + 4
    end
    i += 1
  end
  return -1
end
             
signal = findSignal(ARGF.read.split(''))
puts signal
