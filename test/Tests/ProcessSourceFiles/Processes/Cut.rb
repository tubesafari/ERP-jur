module MusicMasterTest

  module ProcessSourceFiles

    module Processes

      class Cut < ::Test::Unit::TestCase

        # Normal invocation
        def testNormalUsage
          execute_Process_WithConf({
              :WaveFiles => {
                :FilesList => [
                  {
                    :Name => 'Wave.wav',
                    :Processes => [
                      {
                        :Name => 'Cut',
                        :Begin => '0.1s',
                        :End => '0.9s'
                      }
                    ]
                  }
                ]
          