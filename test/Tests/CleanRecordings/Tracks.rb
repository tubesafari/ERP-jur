
module MusicMasterTest

  module CleanRecordings

    class Tracks < ::Test::Unit::TestCase

      # Clean a single track needing DC offset
      def testSingleTrackWithDCOffset
        execute_Clean_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env1
              }
            }
          }
        },
        :PrepareFiles => getPreparedFiles(:Recorded_Env1_1),
        :FakeWSK => [
          {
            :Input => '01_Source/Record/Env1.1.wav',
            :Output => /^.*\/Dummy\.wav$/,
            :Action => 'Analyze',
            :UseWave => 'Empty.wav',
            :CopyFiles => { 'Analysis/Env1.1.analyze' => 'analyze.result' }
          },
          {
            :Input => '01_Source/Record/Env1.Silence.wav',
            :Output => /^.*\/Dummy\.wav$/,
            :Action => 'FFT',
            :UseWave => 'Empty.wav',
            :CopyFiles => { 'FFT/Env1.Silence.fftprofile' => 'fft.result' }
          },
          {
            :Input => '01_Source/Record/Env1.Silence.wav',
            :Output => /^.*\/Dummy\.wav$/,
            :Action => 'Analyze',
            :UseWave => 'Empty.wav',
            :CopyFiles => { 'Analysis/Env1.Silence.analyze' => 'analyze.result' }
          },
          {
            :Input => '01_Source/Record/Env1.1.wav',
            :Output => '02_Clean/Record/Env1.1.01.SilenceRemover.wav',
            :Action => 'SilenceRemover',
            :Params => [ '--silencethreshold', '-3604,3607', '--attack', '0', '--release', '1s', '--noisefft', 'Analyze/Record/Env1.Silence.fftprofile' ],
            :UseWave => '02_Clean/Record/Env1.1.01.SilenceRemover.wav'
          },
          {
            :Input => '02_Clean/Record/Env1.1.01.SilenceRemover.wav',
            :Output => '02_Clean/Record/Env1.1.03.DCShifter.wav',
            :Action => 'DCShifter',
            :Params => [ '--offset', '2' ],
            :UseWave => '02_Clean/Record/Env1.1.03.DCShifter.wav'
          },
          {
            :Input => '02_Clean/Record/Env1.1.03.DCShifter.wav',
            :Output => '02_Clean/Record/Env1.1.04.NoiseGate.wav',
            :Action => 'NoiseGate',
            :Params => [ '--silencethreshold', '-3602,3609', '--attack', '0.1s', '--release', '0.1s', '--silencemin', '1s', '--noisefft', 'Analyze/Record/Env1.Silence.fftprofile' ],
            :UseWave => '02_Clean/Record/Env1.1.04.NoiseGate.wav'
          }
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert File.exists?('Analyze/Record/Env1.1.analyze')
          assert File.exists?('Analyze/Record/Env1.Silence.analyze')
          assert File.exists?('Analyze/Record/Env1.Silence.fftprofile')
          assert File.exists?('02_Clean/Record/Env1.1.01.SilenceRemover.wav')
          assert !File.exists?('02_Clean/Record/Env1.1.02.Cut.0.01s_0.16s.wav')
          assert File.exists?('02_Clean/Record/Env1.1.03.DCShifter.wav')
          assert File.exists?('02_Clean/Record/Env1.1.04.NoiseGate.wav')
        end
      end

      # Clean a single track without DC offset
      def testSingleTrackWithoutDCOffset
        execute_Clean_WithConf({
          :Recordings => {
            :Tracks => {
              [2] => {
                :Env => :Env1
              }
            }
          }
        },
        :PrepareFiles => getPreparedFiles(:Recorded_Env1_2),
        :FakeWSK => [
          {
            :Input => '01_Source/Record/Env1.2.wav',
            :Output => /^.*\/Dummy\.wav$/,
            :Action => 'Analyze',
            :UseWave => 'Empty.wav',
            :CopyFiles => { 'Analysis/Env1.2.analyze' => 'analyze.result' }
          },
          {
            :Input => '01_Source/Record/Env1.Silence.wav',
            :Output => /^.*\/Dummy\.wav$/,
            :Action => 'FFT',
            :UseWave => 'Empty.wav',
            :CopyFiles => { 'FFT/Env1.Silence.fftprofile' => 'fft.result' }
          },
          {
            :Input => '01_Source/Record/Env1.Silence.wav',
            :Output => /^.*\/Dummy\.wav$/,
            :Action => 'Analyze',
            :UseWave => 'Empty.wav',
            :CopyFiles => { 'Analysis/Env1.Silence.analyze' => 'analyze.result' }
          },
          {
            :Input => '01_Source/Record/Env1.2.wav',
            :Output => '02_Clean/Record/Env1.2.01.SilenceRemover.wav',
            :Action => 'SilenceRemover',
            :Params => [ '--silencethreshold', '-3602,3609', '--attack', '0', '--release', '1s', '--noisefft', 'Analyze/Record/Env1.Silence.fftprofile' ],
            :UseWave => '02_Clean/Record/Env1.2.01.SilenceRemover.wav'
          },