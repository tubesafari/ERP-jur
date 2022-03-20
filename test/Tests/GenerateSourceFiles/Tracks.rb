
module MusicMasterTest

  module GenerateSourceFiles

    class Tracks < ::Test::Unit::TestCase

      # Record no track
      def testEmptyTracks
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {}
          }
        }) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
        end
      end