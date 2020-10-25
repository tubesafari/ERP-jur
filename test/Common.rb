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
      #   * *:RecordedFiles* (<em>list<String></em>): List of recorded files to provide to the recorder. Each file can be either the base name (without .wav extension) from a wave file from test/Wave (in this case a temporary file will be copied from this wave file), or a complete wave file name (in this case the RecordedFileGetter just returns this file name) [optional = []]
      #   * *:PrepareFiles* (<em>list< [String,String] ></em>): The list of files to copy from test/ to the test working directory before executing the binary [optional = []]
      #   * *:FakeWSK* (<em>list<map<String,Object>></em>): The list of fake WSK commands to receive [optional = []]:
      #     * *:Input* (_Object_): Name of the input file expected (can be a String or a RegExp)
      #     * *:Output* (_Object_): Name of the output file expected (can be a String or a RegExp)
      #     * *:Action* (_String_): Name of the action expected
      #     * *:Params* (<em>list<String></em>): List of parameters for the action [optional = []]
      #     * *:UseWave* (_String_): Path to the Wave file to be used (relative to the test/Wave folder) to generate the result
      #     * *:CopyFiles* (<em>map<String,String></em>): Additional files to be copied (source => destination) (source being relative to the test folder) [optional = {}]
      #   * *:FakeSSRC* (<em>list<map<String,Object>></em>): The list of fake SSRC commands to receive [optional = []]:
      #     * *:Input* (_Object_): Name of the input file expected (can be a String or a RegExp)
      #     * *:Output* (_Object_): Name of the output file expected (can be a String or a RegExp)
      #     * *:Params* (<em>list<String></em>): List of parameters [optional = []]
      #     * *:UseWave* (_String_): Path to the Wave file to be used (relative to the test/Wave folder) to generate the result
      #   * *:PilotingCode* (_Proc_): The code called to pilot the process [optional = nil]:
      #     * *oStdIN* (_IO_): The process' STDIN
      #     * *iStdOUT* (_IO_): The process' STDOUT
      #     * *iStdERR* (_IO_): The process' STDERR
      #     * *iChildProcess* (_ChildProcessInfo_): The corresponding ChildProcessInfo
      # * *CodeBlock*: Code called once it has been executed:
      #   * *iStdOUTLog* (_String_): Log STDOUT of the process
      #   * *iStdERRLog* (_String_): Log STDERR of the process
      #   * *iExitStatus* (_Integer_): Exit status
      def execute_binary(iBinName, iParams, iOptions = {})
        setupWorkingDir do |iWorkingDir|
          lRootPath = MusicMasterTest::getRootPath
          # Set the MusicMaster config file
          ENV['MUSICMASTER_CONF_PATH'] = "#{lRootPath}/test/DefaultMusicMaster.conf.rb"
          # Set the list of files to be recorded in a file.
          # This way we can compare the file's content after performance to make sure all files were marked as recorded.
          lLstFilesToBeRecorded = (iOptions[:RecordedFiles] || [])
          File.open('MMT_RecordedFiles.rb', 'w') { |oFile| oFile.write(lLstFilesToBeRecorded.inspect) }
          File.open('MMT_FakeWSK.rb', 'w') { |oFile| oFile.write((iOptions[:FakeWSK] || []).inspect) } if (!$MusicMasterTest_UseWSK)
          File.open('MMT_FakeSSRC.rb', 'w') { |oFile| oFile.write((iOptions[:FakeSSRC] || []).inspect) } if (!$MusicMasterTest_UseSSRC)
          log_debug "Setup files to be recorded: #{eval(File.read('MMT_RecordedFiles.rb')).join(', ')}" if (MusicMasterTest::debug?) and (!lLstFilesToBeRecorded.empty?)
          # Prepare files
          lPrepareFiles = (iOptions[:PrepareFiles] || [])
          lPrepareFiles.each do |iFileInfo|
            iSrcName, iDstName = iFileInfo
            FileUtils::mkdir_p(File.dirname(iDstName))
            if (iSrcName[0..0] == '*')
              # Create a shortcut
              log_debug "Create Shortcut #{iSrcName[1..-1]} => #{iDstName}"
              create_shortcut(iSrcName[1..-1], iDstName)
            else
              # Copy the file
              log_debug "Copy file #{lRootPath}/test/#{iSrcName} => #{iDstName}"
              FileUtils::cp("#{lRootPath}/test/#{iSrcName}", iDstName)
            end
          end
          # Set environmnet variables that will be used to trap some behaviour
          ENV['MMT_ROOTPATH'] = lRootPath
          lCmd = [ "#{lRootPath}/bin/#{iBinName}.rb" ] + iParams
          if (MusicMasterTest::debug?)
            ENV['MMT_DEBUG'] = '1'
            lCmd << '--debug'
          end
          lRubyCmdLine = [ 'ruby', '-w', "-I#{lRootPath}/lib" ]
          log_debug "#{Dir.getwd}> #{lRubyCmdLine.inspect} #{lCmd.inspect} ..." if (MusicMasterTest::debug?)
          if (MusicMasterTest::debug?)
            [ 'MUSICMASTER_CONF_PATH', 'MMT_ROOTPATH', 'MMT_DEBUG' ].each do |iVarName|
              log_debug "export #{iVarName}=#{ENV[iVarName]}"
            end
            log_debug "cd #{Dir.getwd}"
            log_debug "#{lRubyCmdLine.join(' ')} #{lCmd.join(' ')}"
          end
          lExitStatus = nil
          lStdOUTLog = nil
          lStdERRLo