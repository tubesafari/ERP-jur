module MusicMasterTest

  module ProcessSourceFiles

    module Processes

      class CutFirstSignal < ::Test::Unit::TestCase

        # Normal invocation
        def testNormalUsage
          execute_Process_WithConf({
              :WaveFiles => {
                :FilesList => [
                  {
                    :Name => 'Wave.wav',
                    :Processes => [
                      {
                        :Name => 'CutFirstSignal',
                        :SilenceMin => '1s'
                      }
                    ]
                  }
                ]
  