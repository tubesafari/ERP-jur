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
require 'rUtilAnts/Platform'
RUtilAnts::Platform.install_platform_on_object

module Test

  module Unit

    class TestCase

      # Get a brand new working dir.
      # Set current directory in this working directory.
      #
      # Parameters::
      # * *CodeBlock*: Code called once working dir has been set up.
      #   * *iWorkingDir* (_String_): The working directory to be used
      def setupWorkingDir
        lWorkingDir = "#{MusicMasterTest::getTmpDir}/WorkingDir"
        FileUtils::rm_rf(lWorkingDir) if File.exists?(lWorki