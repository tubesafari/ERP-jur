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
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam2'
                      }
                    ]
                  }
                },
                :Processes => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam3'
                  }
                ]
              }
            }
          },
          :PrepareFiles => [
            [ 'Wave/01_Source/Wave/Wave1.wav', 'Wave1.wav' ],
            [ 'Wave/01_Source/Wave/Wave2.wav', 'Wave2.wav' ]
          ],
          :FakeWSK => [
            {
              :Input => /05_Mix\/Wave1\.0\.Test\.[[:xdigit:]]{32,32}\.wav/,
              :Output => /05_Mix\/Final\.[[:xdigit:]]{32,32}\.wav/,
              :Action => 'Mix',
              :Params => [ '--files', /05_Mix\/Wave2\.0\.Test\.[[:xdigit:]]{32,32}\.wav\|1/ ],
              :UseWave => '05_Mix/Wave1.Wave2.wav'
            }
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          lWave0FileName = getFileFromGlob('05_Mix/Wave1.0.Test.????????????????????????????????.wav')
          lWave1FileName = getFileFromGlob('05_Mix/Wave2.0.Test.????????????????????????????????.wav')
          lWave2FileName = getFileFromGlob('05_Mix/Final.????????????????????????????????.wav')
          lWave3FileName = getFileFromGlob('05_Mix/Final.0.Test.????????????????????????????????.wav')
          assert_rb_content [
            {
              :InputFileName => 'Wave1.wav',
              :OutputFileName => lWave0FileName,
              :Params => {
                :Param1 => 'TestParam1'
              }
            },
            {
              :InputFileName => 'Wave2.wav',
              :OutputFileName => lWave1FileName,
              :Params => {
                :Param1 => 'TestParam2'
              }
            },
            {
              :InputFileName => lWave2FileName,
              :OutputFileName => lWave3FileName,
              :Params => {
                :Param1 => 'TestParam3'
              }
            }
          ], 'Process_Test.rb'
          assert_wave_lnk '05_Mix/Wave1.Wave2', '05_Mix/Final/Final.wav'
        end
      end

      # Respect processing order with a tree
      # Here is the mix tree:
      # Final
      # +-Mix1
      # | +-Wave1
      # | +-Wave2
      # +-Mix2
      #   +-Wave3
      #   +-Wave4
      def testProcessOrderTree
        execute_Mix_WithConf({
            :WaveFiles => {
              :FilesList => [
                {
                  :Name => 'Wave1.wav'
                },
                {
                  :Name => 'Wave2.wav'
                },
                {
                  :Name => 'Wave3.wav'
                },
                {
                  :Name => 'Wave4.wav'
                }
              ]
            },
            :Mix => {
              'Mix1' => {
                :Tracks => {
                  'Wave1.wav' => {
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam_Wave1'
                      }
                    ]
                  },
                  'Wave2.wav' => {
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam_Wave2'
                      }
                    ]
                  }
                },
                :Processes => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam_Mix1'
                  }
                ]
              },
              'Mix2' => {
                :Tracks => {
                  'Wave3.wav' => {
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam_Wave3'
                      }
                    ]
                  },
                  'Wave4.wav' => {
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam_Wave4'
                      }
                    ]
                  }
                },
                :Processes => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam_Mix2'
                  }
      