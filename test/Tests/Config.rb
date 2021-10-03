module MusicMasterTest

  class Config < ::Test::Unit::TestCase

    # Missing config file
    def testMissingConfigFile
      execute_Record([]) do |iStdOUTLog, iStdERRLog, iExitStatus|
        assert_exitstatus 1, iExitStatus
        assert_match 'Please specify 1 config file', iStdERRLog
      end
    end

    # E