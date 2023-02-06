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
                          :Function => {
                            :FunctionType => WSK::Functions::FCTTYPE_PIECEWISE_LINEAR,
                            :MinValue => 0,
                            :MaxValue => 1,
                            :Points => {
                        