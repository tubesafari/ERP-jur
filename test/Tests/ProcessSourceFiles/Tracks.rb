
module MusicMasterTest

  module ProcessSourceFiles

    class Tracks < ::Test::Unit::TestCase

      # No processing
      def testNoProcessing
        execute_Process_WithConf({
            :Recordings => {
              :Tracks => {
                [1] => {
                  :Env => :Env1
                }
              }
            }
          },
          :PrepareFiles => getPreparedFiles(:Recorded_Env1_1, :Cleaned_Env1_1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert !File.exists?('04_Process/Record')
        end
      end

      # Processing attached to a specific recording
      def testProcessingRecording
        execute_Process_WithConf({
            :Recordings => {
              :Tracks => {
                [1] => {
                  :Env => :Env1,
                  :Processes => [
                    {
                      :Name => 'Test',
                      :Param1 => 'TestParam1'
                    }
                  ]
                }
              }
            }
          },
          :PrepareFiles => getPreparedFiles(:Recorded_Env1_1, :Cleaned_Env1_1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          lWave0FileName = getFileFromGlob('04_Process/Record/Env1.1.04.NoiseGate.0.Test.????????????????????????????????.wav')
          assert_rb_content [
            {
              :InputFileName => '02_Clean/Record/Env1.1.04.NoiseGate.wav',
              :OutputFileName => lWave0FileName,
              :Params => {
                :Param1 => 'TestParam1'
              }
            }
          ], 'Process_Test.rb'
        end
      end

      # Processing attached to the recording environment - before
      def testProcessingRecordingEnvBefore
        execute_Process_WithConf({
            :Recordings => {
              :Tracks => {
                [1] => {
                  :Env => :Env1
                }
              },
              :EnvProcesses_Before => {
                :Env1 => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam1'
                  }
                ]
              }
            }
          },
          :PrepareFiles => getPreparedFiles(:Recorded_Env1_1, :Cleaned_Env1_1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          lWave0FileName = getFileFromGlob('04_Process/Record/Env1.1.04.NoiseGate.0.Test.????????????????????????????????.wav')
          assert_rb_content [
            {
              :InputFileName => '02_Clean/Record/Env1.1.04.NoiseGate.wav',
              :OutputFileName => lWave0FileName,
              :Params => {
                :Param1 => 'TestParam1'
              }
            }
          ], 'Process_Test.rb'
        end
      end

      # Processing attached to the recording environment - after
      def testProcessingRecordingEnvAfter
        execute_Process_WithConf({
            :Recordings => {
              :Tracks => {
                [1] => {
                  :Env => :Env1
                }
              },
              :EnvProcesses_After => {
                :Env1 => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam1'
                  }
                ]
              }
            }
          },
          :PrepareFiles => getPreparedFiles(:Recorded_Env1_1, :Cleaned_Env1_1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          lWave0FileName = getFileFromGlob('04_Process/Record/Env1.1.04.NoiseGate.0.Test.????????????????????????????????.wav')
          assert_rb_content [
            {
              :InputFileName => '02_Clean/Record/Env1.1.04.NoiseGate.wav',
              :OutputFileName => lWave0FileName,
              :Params => {
                :Param1 => 'TestParam1'
              }
            }
          ], 'Process_Test.rb'
        end
      end

      # Processing attached globally before
      def testProcessingRecordingGlobalBefore
        execute_Process_WithConf({
            :Recordings => {
              :Tracks => {
                [1] => {
                  :Env => :Env1
                }
              },
              :GlobalProcesses_Before => [
                {
                  :Name => 'Test',
                  :Param1 => 'TestParam1'
                }
              ]
            }
          },
          :PrepareFiles => getPreparedFiles(:Recorded_Env1_1, :Cleaned_Env1_1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          lWave0FileName = getFileFromGlob('04_Process/Record/Env1.1.04.NoiseGate.0.Test.????????????????????????????????.wav')
          assert_rb_content [
            {
              :InputFileName => '02_Clean/Record/Env1.1.04.NoiseGate.wav',
              :OutputFileName => lWave0FileName,
              :Params => {
                :Param1 => 'TestParam1'
              }
            }
          ], 'Process_Test.rb'
        end
      end

      # Processing attached globally after
      def testProcessingRecordingGlobalAfter
        execute_Process_WithConf({
            :Recordings => {
              :Tracks => {
                [1] => {
                  :Env => :Env1
                }
              },
              :GlobalProcesses_After => [
                {
                  :Name => 'Test',
                  :Param1 => 'TestParam1'
                }
              ]
            }
          },
          :PrepareFiles => getPreparedFiles(:Recorded_Env1_1, :Cleaned_Env1_1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          lWave0FileName = getFileFromGlob('04_Process/Record/Env1.1.04.NoiseGate.0.Test.????????????????????????????????.wav')
          assert_rb_content [
            {
              :InputFileName => '02_Clean/Record/Env1.1.04.NoiseGate.wav',
              :OutputFileName => lWave0FileName,
              :Params => {
                :Param1 => 'TestParam1'
              }
            }
          ], 'Process_Test.rb'
        end
      end

      # Otder of processing has to be respected
      def testProcessingOrder
        execute_Process_WithConf({
            :Recordings => {
              :Tracks => {
                [1] => {
                  :Env => :Env1,
                  :Processes => [
                    {
                      :Name => 'Test',
                      :Param1 => 'TestParam2'
                    }
                  ]
                }
              },
              :EnvProcesses_Before => {
                :Env1 => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam1'
                  }
                ]
              },
              :EnvProcesses_After => {
                :Env1 => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam3'
                  }
                ]
              },
              :GlobalProcesses_Before => [
                {
                  :Name => 'Test',