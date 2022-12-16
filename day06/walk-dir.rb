class Directory
  def initialize(path)
    @path = path
    @subdirs = {}
    @files = {}
  end

  def size
    @subdirs.values.map(&:size).sum + @files.values.sum
  end

  def addChild(child, dir)
    @subdirs[child] = dir
  end

  def addFile(name, size)
    @files[name] = size.to_i
  end

  def getChildDir(name)
    @subdirs[name]
  end
    
end


currentDir = root = Directory.new('/')
currentPath = ['']
fullPath = '/'

dirs = {'/' => root}
inList = false

def getFullPath(dirs)
  if dirs.size == 1
    return dirs[0] == '' ? '/' : dirs[0]
  end
  dirs.join('/')
end


ARGF.readlines.each do |line|
  puts "doing line #{line} at path #{fullPath}"
  line.chomp!
  m = /^\$\s+cd\s+(.+)$/.match(line)
  if m
    inList = false
    case m[1]
    when '/'
      currentPath = ['']
      fullPath = '/'
      currentDir = dirs['/']

    when '..'
      currentPath.pop
      if currentPath.size == 0
        currentPath = ['']
      end
      fullPath = getFullPath(currentPath)
      currentDir = dirs[fullPath]
      abort("Can't find dir #{ fullPath }") if !currentDir

    else
      newDirname = m[1]
      newDir = currentDir.getChildDir(newDirname)
      abort("Never saw dir #{newDirname} in path #{fullPath}") if !newDir
      currentPath.push(newDirname)
      fullPath = getFullPath(currentPath)
      currentDir = newDir
    end
    currentDir = dirs[fullPath]
    next
  end

  m = /^\$\s+ls\s*$/.match(line)
  if m
    inList = true
    next
  end

  if !inList
    abort("Not processing ls with command #{line}")
  end
  
  m = /^(\d+)\s+(.+)$/.match(line)
  if m
    currentDir.addFile(m[2], m[1])
    next
  end
  
  m = /^dir\s+(.+)$/.match(line)
  if m
    dirname = m[1]
    childPath = (currentPath + [dirname]).join('/')
    childDir = dirs[childPath]
    if !childDir
      newDir = Directory.new(childPath)
      currentDir.addChild(dirname, newDir)
      dirs[childPath] = newDir
    end
    next
  end

  abort("Can't process line #{line}")
end
    
require 'pp'

# PP.pp dirs

sizes = {}
smallSizes = []
dirs.each do |fullPath, dir|
  sizes[fullPath] = dir.size
  if sizes[fullPath] <= 100000
    smallSizes << sizes[fullPath]
  end
end

PP.pp sizes
# puts smallSizes.sum

totalDiskSpace =    70_000_000
requiredFreeSpace = 30_000_000
currentUsedSpace = sizes['/']
puts currentUsedSpace # 48_748_071

puts spaceNeedToFree = currentUsedSpace - requiredFreeSpace # 18_748_071

# Find the largest directory <= spaceNeedToFree

puts sizes.entries.filter{|entry| entry[1] >= spaceNeedToFree}.
      sort{|a, b| a[1] <=> b[1]}[0]

(rdb:1) spaceUsed = 48748071
48748071
(rdb:1) spaceAvail = 70_000_000 - spaceUsed
21251929
(rdb:1) freeUpNeeded = 30_000_000 - spaceAvail
8748071
(rdb:1) sizes.entries.filter{|entry| entry[1] >= freeUpNeeded}.size
7
(rdb:1) sizes.entries.filter{|entry| entry[1] >= freeUpNeeded}.sort{|a[1] <=> b[1]}[0]
/Users/ericp/.rbenv/versions/2.7.1/lib/ruby/2.7.0/debug.rb:286:in `eval':walk-dir.rb:128: syntax error, unexpected '[', expecting '|'
...ry[1] >= freeUpNeeded}.sort{|a[1] <=> b[1]}[0]
