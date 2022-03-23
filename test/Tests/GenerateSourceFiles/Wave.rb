module MusicMasterTest

  module GenerateSourceFiles

    class Wave < ::Test::Unit::TestCase

      # Test an empty wave files list
      def testNoWaveFiles
        execute_Record_WithConf({
          :WaveFiles => {
            :FilesList => []
          }
        }) do |iStdOUTLog