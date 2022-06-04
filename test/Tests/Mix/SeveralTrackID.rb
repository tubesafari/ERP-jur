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
                ]
              },
              'Final' => {
                :Tracks => {
                  'Mix1' => {
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam_Mix1_2'
                      }
                    ]
                  },
                  'Mix2' => {
                    :Processes => [
                      {
                        :Name => 'Test',
                        :Param1 => 'TestParam_Mix2_2'
                      }
                    ]
                  }
                },
                :Processes => [
                  {
                    :Name => 'Test',
                    :Param1 => 'TestParam_Final'
                  }
                ]
              }
            }
          },
          :PrepareFiles => [
            [ 'Wave/01_Source/Wave/Wave1.wav', 'Wave1.wav' ],
            [ 'Wave/01_Source/Wave/Wave2.wav', 'Wave2.wav' ],
            [ 'Wave/01_Source/Wave/Wave3.wav', 'Wave3.wav' ],
            [ 'Wave/01_Source/Wave/Wave4.wav', 'Wave4.wav' ]
          ],
          :FakeWSK => [
            {
              :Input => /05_Mix\/Wave1\.0\.Test\.[[:xdigit:]]{32,32}\.wav/,
              :Output => /05_Mix\/Mix1\.[[:xdigit:]]{32,32}\.wav/,
              :Action => 'Mix',
              :Params => [ '--files', /05_Mix\/Wave2\.0\.Test\.[[:xdigit:]]{32,32}\.wav\|1/ ],
              :UseWave => '05_Mix/Wave1.Wave2.wav'
            },
            {
              :Input => /05_Mix\/Wave3\.0\.Test\.[[:xdigit:]]{32,32}\.wav/,
              :Output => /05_Mix\/Mix2\.[[:xdigit:]]{32,32}\.wav/,
              :Action => 'Mix',
              :Params => [ '--files', /05_Mix\/Wave4\.0\.Test\.[[:xdigit:]]{32,32}\.wav\|1/ ],
              :UseWave => '05_Mix/Wave3.Wave4.wav'
            },
            {
              :Input => /05_Mix\/Mix1\.0\.Test\.0\.Test\.[[:xdigit:]]{32,32}\.wav/,
              :Output => /05_Mix\/Final\.[[:xdigit:]]{32,32}\.wav/,
              :Action => 'Mix',
              :Params => [ '--files', /05_Mix\/Mix2\.0\.Test\.0\.Test\.[[:xdigit:]]{32,32}\.wav\|1/ ],
              :UseWave => '05_Mix/Wave1.Wave2.Wave3.Wave4.wav'
            }
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          lWave1ProcessedFileName = getFileFromGlob('05_Mix/Wave1.0.Test.????????????????????????????????.wav')
          lWave2ProcessedFileName = getFileFromGlob('05_Mix/Wave2.0.Test.????????????????????????????????.wav')
          lMix1FileName = getFileFromGlob('05_Mix/Mix1.????????????????????????????????.wav')
          lMix1MixFileName = getFileFromGlob('05_Mix/Mix1.0.Test.????????????????????????????????.wav')
          lWave3ProcessedFileName = getFileFromGlob('05_Mix/Wave3.0.Test.????????????????????????????????.wav')
          lWave4ProcessedFileName = getFileFromGlob('05_Mix/Wave4.0.Test.????????????????????????????????.wav')
          lMix2FileName = getFileFromGlob('05_Mix/Mix2.????????????????????????????????.wav')
          lMix2MixFileName = getFileFromGlob('05_Mix/Mix2.0.Test.????????????????????????????????.wav')
          lMix1ProcessedFileName = getFileFromGlob('05_Mix/Mix1.0.Test.0.Test.????????????????????????????????.wav')
          lMix2ProcessedFileName = getFileFromGlob('05_Mix/Mix2.0.Test.0.Test.????????????????????????????????.wav')
          lFinalFileName = getFileFromGlob('05_Mix/Final.????????????????????????????????.wav')
          lFinalMixFileName = getFileFromGlob('05_Mix/Final.0.Test.????????????????????????????????.wav')
          assert_rb_content [
            {
              :InputFileName => 'Wave1.wav',
              :OutputFileName => lWave1ProcessedFileName,
              :Params => {
                :Param1 => 'TestParam_Wave1'
              }
            },
            {
              :InputFileName => 'Wave2.wav',
              :OutputFileName => lWave2ProcessedFileName,
              :Params => {
                :Param1 => 'TestParam_Wave2'
              }
            },
            {
              :InputFileName => lMix1FileName,
              :OutputFileName => lMix1MixFileName,
              :Params => {
                :Param1 => 'TestParam_Mix1'
              }
            },
            {
              :InputFileName => lMix1MixFileName,
              :OutputFileName => lMix1ProcessedFileName,
              :Params => {
                :Param1 => 'TestParam_Mix1_2'
              }
            },
            {
              :InputFileName => 'Wave3.wav',
              :OutputFileName => lWave3ProcessedFileName,
              :Params => {
                :Param1 => 'TestParam_Wave3'
              }
            },
            {
              :InputFileName => 'Wave4.wav',
              :OutputFileName => lWave4ProcessedFileName,
              :Params => {
                :Param1 => 'TestParam_Wave4'
              }
            },
            {
              :InputFileName => lMix2FileName,
              :OutputFileName => lMix2MixFileName,
              :Params => {
                :Param1 => 'TestParam_Mix2'
              }
            },
            {
              :InputFileName => lMix2MixFileName,
              :OutputFileName => lMix2ProcessedFileName,
              :Params => {
                :Param1 => 'TestParam_Mix2_2'
              }
            },
            {
              :InputFileName => lFinalFileName,
              :OutputFileName => lFinalMixFileName,
              :Params => {
                :Param1 => 'TestParam_Final'
              }
            }
          ], 'Process_Test.rb'
          assert_wave_lnk '05_Mix/Wave1.Wave2', '05_Mix/Final/Mix1.wav'
          assert_wave_lnk '05_Mix/Wave3.Wave4', '05_Mix/Final/Mix2.wav'
          assert_wave_lnk '05_Mix/Wave1.Wave2.Wave3.Wave4', '05_Mix/Final/Final.wav'
        end
      end

      # Useless processing in a tree
      # Here is the mix tree:
      # Final
      # +-Mix1
      # | +-Wave1
      # | +-Wave2
      # +-Mix2
      #   +-Wave3
      #   +-Wave4
      def testUselessProcessOrderTree
        execute_Mix_WithConf({
            :WaveFiles => {
              :FilesList => [
                {
                  :Name => 'Wave1.wav'
                },
                {
                  :N