
module MusicMasterTest

  module GenerateSourceFiles

    class Tracks < ::Test::Unit::TestCase

      # Record no track
      def testEmptyTracks
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {}
          }
        }) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
        end
      end

      # Record a single track
      def testSingleTrack
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Track1
              }
            }
          }
        }, :RecordedFiles => [
          'Empty', # Track 1 recording
          'Empty'  # Track 1 silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Track1.1.wav'
          assert_wave 'Empty', '01_Source/Record/Env_Track1.Silence.wav'
        end
      end

      # Record 2 tracks in 1 shoot
      def testSingle2Tracks
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1, 2] => {
                :Env => :Env_Tracks
              }
            }
          }
        }, :RecordedFiles => [
          'Empty', # Track recording
          'Empty'  # Track silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Tracks.1.2.wav'
          assert_wave 'Empty', '01_Source/Record/Env_Tracks.Silence.wav'
        end
      end

      # Record 2 tracks in their own environment
      def test2Tracks
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Track1
              },
              [2] => {
                :Env => :Env_Track2
              }
            }
          }
        }, :RecordedFiles => [
          'Empty', # Track 1 recording
          'Empty', # Track 1 silence
          'Empty', # Track 2 recording
          'Empty'  # Track 2 silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Track1.1.wav'
          assert_wave 'Empty', '01_Source/Record/Env_Track1.Silence.wav'
          assert_wave 'Empty', '01_Source/Record/Env_Track2.2.wav'
          assert_wave 'Empty', '01_Source/Record/Env_Track2.Silence.wav'
        end
      end

      # Record 2 tracks in their own environment with a specific order - 1
      def test2TracksWithOrder1
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Track1
              },
              [2] => {
                :Env => :Env_Track2
              }
            },
            :EnvRecordingOrder => [:Env_Track1, :Env_Track2]
          }
        }, :RecordedFiles => [
          # Use different recorded files to make sure it is recorded in a sorted way
          'Empty', # Track 1 recording
          'Noise1s', # Track 1 silence
          'Silence1s', # Track 2 recording
          'Whistle1s'  # Track 2 silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Track1.1.wav'
          assert_wave 'Noise1s', '01_Source/Record/Env_Track1.Silence.wav'
          assert_wave 'Silence1s', '01_Source/Record/Env_Track2.2.wav'
          assert_wave 'Whistle1s', '01_Source/Record/Env_Track2.Silence.wav'
        end
      end

      # Record 2 tracks in their own environment with a specific order - 2
      def test2TracksWithOrder2
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Track1
              },
              [2] => {
                :Env => :Env_Track2
              }
            },
            :EnvRecordingOrder => [:Env_Track2, :Env_Track1]
          }
        }, :RecordedFiles => [
          # Use different recorded files to make sure it is recorded in a sorted way
          'Empty', # Track 2 recording
          'Noise1s', # Track 2 silence
          'Silence1s', # Track 1 recording
          'Whistle1s'  # Track 1 silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Track2.2.wav'
          assert_wave 'Noise1s', '01_Source/Record/Env_Track2.Silence.wav'
          assert_wave 'Silence1s', '01_Source/Record/Env_Track1.1.wav'
          assert_wave 'Whistle1s', '01_Source/Record/Env_Track1.Silence.wav'
        end
      end

      # Record 2 tracks sharing the same environment
      def test2TracksSameEnv
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Tracks
              },
              [2] => {
                :Env => :Env_Tracks
              }
            }
          }
        }, :RecordedFiles => [
          # Use different recorded files to make sure it is recorded in a sorted way
          'Empty', # Track 1 recording
          'Empty', # Track 2 recording
          'Whistle1s'  # Tracks silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Tracks.1.wav'
          assert_wave 'Empty', '01_Source/Record/Env_Tracks.2.wav'
          assert_wave 'Whistle1s', '01_Source/Record/Env_Tracks.Silence.wav'
        end
      end

      # Record a track needing calibration
      def testTrackWithCalibration
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Track1,
                :CalibrateWithEnv => :Env_Ref
              }
            },
            :EnvRecordingOrder => [:Env_Track1, :Env_Ref]
          }
        }, :RecordedFiles => [
          # Use different recorded files to make sure it is recorded in a sorted way
          'Empty', # Track 1 recording
          'Noise1s', # Track 1 calibration
          'Whistle1s',  # Track 1 silence
          'Silence1s', # Ref calibration
          'Sine1s'  # Ref silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Track1.1.wav'
          assert_wave 'Noise1s', '01_Source/Record/Calibration.Env_Track1.Env_Ref.wav'
          assert_wave 'Whistle1s', '01_Source/Record/Env_Track1.Silence.wav'
          assert_wave 'Silence1s', '01_Source/Record/Calibration.Env_Ref.Env_Track1.wav'
          assert_wave 'Sine1s', '01_Source/Record/Env_Ref.Silence.wav'
        end
      end

      # Record a track needing calibration with a different order
      def testTrackWithCalibrationOrder
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Track1,
                :CalibrateWithEnv => :Env_Ref
              }
            },
            :EnvRecordingOrder => [:Env_Ref, :Env_Track1]
          }
        }, :RecordedFiles => [
          # Use different recorded files to make sure it is recorded in a sorted way
          'Silence1s', # Ref calibration
          'Sine1s',  # Ref silence
          'Empty', # Track 1 recording
          'Noise1s', # Track 1 calibration
          'Whistle1s'  # Track 1 silence
        ]) do |iStdOUTLog, iStdERRLog, iExitStatus|
          assert_exitstatus 0, iExitStatus
          assert_wave 'Empty', '01_Source/Record/Env_Track1.1.wav'
          assert_wave 'Noise1s', '01_Source/Record/Calibration.Env_Track1.Env_Ref.wav'
          assert_wave 'Whistle1s', '01_Source/Record/Env_Track1.Silence.wav'
          assert_wave 'Silence1s', '01_Source/Record/Calibration.Env_Ref.Env_Track1.wav'
          assert_wave 'Sine1s', '01_Source/Record/Env_Ref.Silence.wav'
        end
      end

      # Record 2 tracks needing calibration on the same environment
      def test2TracksWithCalibration
        execute_Record_WithConf({
          :Recordings => {
            :Tracks => {
              [1] => {
                :Env => :Env_Track1,
                :CalibrateWithEnv => :Env_Ref
              },
              [2] => {
                :Env => :Env_Track2,
                :CalibrateWithEnv => :Env_Ref
              }
            },
            :EnvRecordingOrder => [:Env_Track1, :Env_Track2, :Env_Ref]
          }
        }, :RecordedFiles => [
          # Use different recorded files to make sure it is recorded in a sorted way
          'Empty', # Track 1 recording
          'Noise1s', # Track 1 calibration
          'Whistle1s',  # Track 1 silence