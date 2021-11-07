module MusicMasterTest

  module Deliver

    class Generic < ::Test::Unit::TestCase

      # Nothing to deliver
      def testNoDeliverable
        execute_Deliver_WithConf({
            :WaveFiles => { :FilesList => [ { :Name => 'Wave1.wav' } ] },
            :Mix => { 'Mix1' => { :Tracks => { 'Wave1.wav' => {} } } }
          },
          :PrepareFiles => getPreparedFiles(:Mixed_Wave1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert !File.exists?('06_Deliver')
        end
      end

      # Simple delivery
      def testSimple
        execute_Deliver_WithConf({
            :WaveFiles => { :FilesList => [ { :Name => 'Wave1.wav' } ] },
            :Mix => { 'Mix1' => { :Tracks => { 'Wave1.wav' => {} } } },
            :Deliver => {
              :Formats => {
                'Test' => {
                  :FileFormat => 'Test'
                }
              },
              :Deliverables => {
                'Deliverable' => {
                  :Mix => 'Mix1',
                  :Format => 'Test'
                }
              }
            }
          },
          :PrepareFiles => getPreparedFiles(:Mixed_Wave1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_rb_content({
            :SrcFileName => 'Wave1.wav',
            :DstFileName => '06_Deliver/Deliverable/Track.test.rb',
            :FormatConf => {},
            :Metadata => { :FileName => 'Track' }
          }, '06_Deliver/Deliverable/Track.test.rb')
        end
      end

      # Simple delivery with a name not fitting on the file system
      def testNotFSName
        execute_Deliver_WithConf({
            :WaveFiles => { :FilesList => [ { :Name => 'Wave1.wav' } ] },
            :Mix => { 'Mix1' => { :Tracks => { 'Wave1.wav' => {} } } },
            :Deliver => {
              :Formats => {
                'Test' => {
                  :FileFormat => 'Test'
                }
              },
              :Deliverables => {
                'Deliverable/With/Bad/Characters' => {
                  :Mix => 'Mix1',
                  :Format => 'Test'
                }
              }
            }
          },
          :PrepareFiles => getPreparedFiles(:Mixed_Wave1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_rb_content({
            :SrcFileName => 'Wave1.wav',
            :DstFileName => '06_Deliver/Deliverable_With_Bad_Characters/Track.test.rb',
            :FormatConf => {},
            :Metadata => { :FileName => 'Track' }
          }, '06_Deliver/Deliverable_With_Bad_Characters/Track.test.rb')
        end
      end

      # Check format parameters
      def testFormatParameters
        execute_Deliver_WithConf({
            :WaveFiles => { :FilesList => [ { :Name => 'Wave1.wav' } ] },
            :Mix => { 'Mix1' => { :Tracks => { 'Wave1.wav' => {} } } },
            :Deliver => {
              :Formats => {
                'Test' => {
                  :FileFormat => 'Test',
                  :Param1 => 'FormatParam1'
                }
              },
              :Deliverables => {
                'Deliverable' => {
                  :Mix => 'Mix1',
                  :Format => 'Test'
                }
              }
            }
          },
          :PrepareFiles => getPreparedFiles(:Mixed_Wave1)
        ) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_rb_content({
            :SrcFileName => 'Wave1.wav',
            :DstFileName => '06_Deliver/Deliverable/Track.test.rb',
            :FormatConf => {
              :Param1 => 'FormatParam1'
            },
            :Metadata => { :FileName => 'Track' }
  