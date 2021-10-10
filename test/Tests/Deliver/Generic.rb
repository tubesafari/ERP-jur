module MusicMasterTest

  module Deliver

    class Generic < ::Test::Unit::TestCase

      # Nothing to deliver
      def testNoDeliverable
        execute_Deliver_WithConf({
            :WaveFiles => { :FilesList => [ { :Name => 'Wave1.wav' } ] },
            :Mix => { 'Mix1' => { :Tracks => { 'Wave1.wav' => {} } } }
          },
          :PrepareFiles => getPreparedFiles(:Mixed_Wave1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          