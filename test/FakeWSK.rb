puts "Fake WSK invoked: #{ARGV.inspect}"

def fail(iStr)
  puts "!!! Fake WSK error: #{iStr}"
  raise iStr
end

def format(iInfo)
  rStr = ":Input => '#{iInfo[:Input]}',\n:Output => '#{iInfo[:Output]}',\n:Action => '#{iInfo[:Action]}',\n"
  rStr.concat(":Params => [ '#{iInfo[:Params].join('\', \'')}' ]") if (iInfo[:Params] != nil)
  return rStr
end

# Check command line
if ((ARGV[0] != '--input') or
    (ARGV[2] != '--output') or
    (ARGV[4] != '--action') or
    (ARGV[