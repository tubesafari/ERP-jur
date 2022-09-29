module MusicMasterTest

  module Mix

    class SingleTrackID < ::Test::Unit::TestCase

      # No mix
      def testNoMix
        execute_Mix_WithConf({
            :WaveFiles => {
              :FilesList => [
                {
                  :Name => 'Wave.wav'
                }
              ]
            },
            :Mix => {
              'Final' => {
                :Tracks => {
                  'Wave.wav' => {}
                }
              }
            }
          },
          :PrepareFiles => [
            [ 'Wave/Empty.wav', 'Wave.wav' ]
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert Dir.glob('05_Mix/*.wav').empty?
          assert_wave_lnk 'Empty', '05_Mix/Final/Final.wav'
        end
   