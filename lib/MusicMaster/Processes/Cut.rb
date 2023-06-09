
module MusicMaster

  module Processes

    class Cut

      # Parameters of this process:
      # * *:Begin* (_String_): The begin marker (either in seconds or in samples)
      # * *:End* (_String_): The end marker (either in seconds or in samples)

      # Execute the process
      #
      # Parameters::
      # * *iInputFileName* (_String_): File name we want to apply effects to
      # * *iOutputFileName* (_String_): File name to write
      # * *iTempDir* (_String_): Temporary directory that can be used
      # * *iParams* (<em>map<Symbol,Object></em>): Parameters
      def execute(iInputFileName, iOutputFileName, iTempDir, iParams)
        wsk(iInputFileName, iOutputFileName, 'Cut', "--begin #{iParams[:Begin]} --end #{iParams[:End]}")
      end

    end

  end

end