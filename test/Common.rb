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
        FileUtils::rm_rf(lWorkingDir) if File.exists?(lWorkingDir)
        FileUtils::mkdir_p(lWorkingDir)
        change_dir(lWorkingDir) do
          yield(lWorkingDir)
        end
        FileUtils::rm_rf(lWorkingDir) if (!MusicMasterTest::debug?)
      end

      # Execute a binary in the test environment with given parameters
      #
      # Parameters::
      # * *iBinName* (_String_): Name of the binary
      # * *iParams* (<em>list<String></em>): Parameters to give to Record
      # * *iOptions* (<em>map<Symbol,Object></em>): Additional options [optional = {}]
      #   * *:RecordedFiles* (<em>list<String></em>): List of recorded files to provide to the recorder. Each file can be either the base name (without .wav extension) from a wave file from test/Wave (in this case a temporary file will be copied from th