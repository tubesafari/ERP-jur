module MusicMasterTest

  module GenerateSourceFiles

    class Wave < ::Test::Unit::TestCase

      # Test an empty wave files list
      def testNoWaveFiles
        execute_Record_WithConf({
          :WaveFiles => {
            :FilesList => []
          }
        }) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
        end
      end

      # Test an existing wave file
      def testExistingWaveFile
        execute_Record_WithConf({
            :WaveFiles => {
              :FilesList => [
                {
                  :Name => 'Wave.wav'
                }
              ]
            }
          },
          :PrepareFiles => [
            [ 'Wave/Empty.wav', 'Wave.wav' ]
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert !File.exists?('01_Source/Wave/Wave.wav')
        end
      end

      # Test generating a missing wave file
      def testGeneratingWaveFile
        execute_Record_WithConf({
          :WaveFiles => {
            :FilesList => [
              {
                :Name => 'Wave.wav'
              }
            ]
          },
        },
        :PilotingCode => Proc.new do |oStdIN, iStdOUT, iStdERR, iChildProcess|
          lWaveFileName = '01_Source/Wave/Wave.wav'
          iStdOUT.gets_until("Create Wave file #{lWaveFileName}, and press Enter when done.\n", :time_out_secs => 10)
          FileUtils::mkdir_p(File.dirname(lWaveFileName