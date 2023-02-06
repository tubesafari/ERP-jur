module MusicMasterTest

  module ProcessSourceFiles

    module Processes

      class ApplyVolumeFct < ::Test::Unit::TestCase

        # Normal invocation
        def testNormalUsage
          ensure_wsk_or_skip do
            execute_Process_WithConf({
                :WaveFiles => {
                  :FilesList => [
                    {
                      :Name => 'Wave.wav',
                      :Processes => [
                        {
                          :Name => 'ApplyVolumeFct',
                    