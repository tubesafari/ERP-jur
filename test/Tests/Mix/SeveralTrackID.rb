module MusicMasterTest

  module Mix

    class SeveralTrackID < ::Test::Unit::TestCase

      # No process
      def testNoProcess
        execute_Mix_WithConf({
            :WaveFiles => {
              :FilesList => [
                {
                  :Name => 'Wave1.wav'
                },
                {
                  :Name => 'Wave2.wav'
                }
              ]
            },
            :Mix => {
              'Final' => {
                :Tracks => {
                  'Wave1.wav' => {},
                  'Wave2.wav' => {}
                }
              }
            }
          },
          :PrepareFiles => [
            [ 'Wave/01_Source/Wave/Wave1.wav', 'Wave1.wav' ],
            [ 'Wave/01_Source/Wave/Wave2.wav', 'Wave2.wav' ]
          ],
          :FakeWSK => [
            {
              :Input => 'Wave1.wav',
              :Output => /05_Mix\/Final\.[[:xdigit:]]{32,32}\.wav/,
              :Action => 'Mix',
              :Params => [ '--files', 'Wave2.wav|1' ],
              :UseWave => '05_Mix/Wave1.Wave2.wav'
            }
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          getFileFromGlob('05_Mix/Final.????????????????????????????????.wav')
          assert_wave_lnk '05_Mix/Wave1.Wave2', '05_Mix/Final/Final.wav'
        end
      end

      # Respect processing order
      def testProcessOrder
        execute_Mix_WithConf({
            :WaveFiles => {
              :FilesList => [
                {
                  :Name => 'Wave1.wav'
                },
                {
                  :Name => 'Wave2.wav'
                }
              ]
            },
            :Mix => {
              'Final' => {
                :Tracks => {
                  'Wave1.wav' => {
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam1'
                      }
                    ]
                  },
                  'Wave2.wav' => {
                    :Processes =