module MusicMasterTest

  module ProcessSourceFiles

    module Processes

      class Custom < ::Test::Unit::TestCase

        # Normal invocation
        def testNormalUsage
          lProcessID = {
            :CustomParam1 => 'Param1Value'
          }.unique_id
          execute_Process_WithConf({
              :WaveFiles => {
                :FilesList => [
                  {
                    :Name => 'Wave.wav',
                    :Processes => [
                      {
                        :Name => 'Custom',
                        :CustomParam1 => 'Param1Value'
                      }
                    ]
                  }
                ]
              }
            },
            :PrepareFiles => [
              [ 'Wave/Empty.wav', 'Wave.wav' ]
            ],
            :PilotingCode => Proc.new do |oStdIN, iStdOUT, iStdERR, iChildProcess|
              lLstLines = iStdOUT.gets_until("Press Enter when done ...\n", :time_out_secs => 10)
              assert_equal "Apply custom proce