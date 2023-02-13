module MusicMasterTest

  module ProcessSourceFiles

    module Processes

      class ApplyVolumeFct < ::Test::Unit::TestCase

        # Normal invocation
        def testNormalUsage
          ensure_wsk_or_skip do
            execute_Process_WithConf({
                :WaveFiles => {
                  :FilesList => [
                    {
                      :Name => 'Wave.wav',
                      :Processes => [
                        {
                          :Name => 'ApplyVolumeFct',
                          :Function => {
                            :FunctionType => WSK::Functions::FCTTYPE_PIECEWISE_LINEAR,
                            :MinValue => 0,
                            :MaxValue => 1,
                            :Points => {
                              0 => 0,
                              1 => 1
                            }
                          },
                          :Begin => '0.1s',
                          :End => '0.9s',
                          :DBUnits => false
                        }
                      ]
                    }
                  ]
                }
              },
              :PrepareFiles => [
                [ 'Wave/Sine1s.wav', 'Wave.wav' ]
              ],
              :FakeWSK => [
                {
                  :Input => 'Wave.wav',
                  :Output => /04_Process\/Wave\/Wave\.0\.ApplyVolumeFct\.[[:xdigit:]]{32,32}\.wav/,
                  :Action => 'ApplyVolumeFct',
                  :Params =