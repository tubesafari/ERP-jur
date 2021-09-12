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
    (ARGV[6] != '--'))
  fail("Invalid parameters for WSK invocation: #{ARGV.inspect}")
end
lReceivedInfo = {
  :Input => ARGV[1],
  :Output => ARGV[3],
  :Action => ARGV[5],
  :Params => (ARGV[7..-1].empty?) ? nil : ARGV[7..-1]
}

# Dequeue the name of the next WSK command
lLstFakeWSK = eval(File.read('MMT_FakeWSK.rb'))
fail("No more WSK calls expected. Called with:\n#{format(lReceivedInfo)}") if (lLstFakeWSK.empty?)
lFakeWSKInfo = lLstFakeWSK.first
File.open('MMT_FakeWSK.rb', 'w') { |oFile| oFile.write(lLstFakeWSK[1..-1].inspect) }

# Check that we expected what we received
lErrors = []
if (lFakeWSKInfo[:Input].is_a?(Regexp))
  lErrors << 'Wrong input file' if (lReceivedInfo[:Input].match(lFakeWSKInfo[:Input]) == nil)
else
  lErrors << 'Wrong input file' if (lFakeWSKInfo[:Input] != lReceivedInfo[:Input])
end
if (lFakeWSKInfo[:Output].is_a?(Regexp))
  lErrors << 'Wrong output file' if (lReceivedInfo[:Output].match(lFakeWSKInfo[:Output]) == nil)
else
  lErrors << 'Wrong output file' if (lFakeWSKInfo[:Output] != lReceivedInfo[:Output])
end
lErrors << 'Wrong action' if (lFakeWSKInfo[:Action] != lReceivedInfo[:Action])
if ((lFakeWSKInfo[:Params] != nil) or
    (lReceivedInfo