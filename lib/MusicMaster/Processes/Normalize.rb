module MusicMaster

  module Processes

    class Normalize

      # Execute the process
      #
      # Parameters::
      # * *iInputFileName* (_String_): File name we want to apply effects to
      # * *iOutputFileName* (_String_): File name to write
      # * *iTempDir* (_String_): Temporary directory that can be used
      # * *iParams* (<em>map<Symbol,Object></em>): Parameters
      def execute(iInputFileName, iOutputFileName, iTempDir, iParams)
        require 'rational'
        # First, analyze
        lAnalyzeResultFileName = "#{iTempDir}/#{File.basename(iInputFileName)}.analyze"
        if (File.exists?(lAnalyzeResultFileName))
          log_warn "File #{lAnalyzeResultFileName} already exists. Will not overwrite it."
        else
  