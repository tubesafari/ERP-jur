require 'tmpdir'
require 'fileutils'
require 'pp'
begin
  require 'processpilot/processpilot'
rescue LoadError
  puts "\n\n!!! Test framework needs ProcessPilot gem to work. Please install it: \"gem install ProcessPilot\"\n\n"
  raise
end
require 'lib/MusicMaster/Hash'
require 'lib/MusicMaster/Symbol'
require 'rUtilAnts