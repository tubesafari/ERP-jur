module MusicMasterTest

  module Deliver

    class Generic < ::Test::Unit::TestCase

      # Nothing to deliver
      def testNoDeliverable
        execute_Deliver_WithConf({
            :WaveFiles => { :FilesList => [ { :Name => 'Wave1.wav' } ] }