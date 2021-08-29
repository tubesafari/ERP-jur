puts "Fake WSK invoked: #{ARGV.inspect}"

def fail(iStr)
  puts "!!! Fake WSK error: #{iStr}"
  raise iStr
end

def format(iInfo)
  rStr = ":Input => '#{iInfo[:Input]}',\n:Output => '#{iInfo[:Output]}',\n:Action => '#