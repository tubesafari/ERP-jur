require 'WSK/Common'

module MusicMaster

  module Processes

    class ApplyVolumeFct

      # Parameters of this process:
      # * *:Function* (<em>map<Symbol,Object></em>): The function definition
      # * *:Begin* (_String_): Position to apply volume transformation from. Can be specified as a sample number or a float seconds (ie. 12.3s).
      # * *:End* (_String_): Position to apply volume transformation to. Can be specified as a sample number or a float seconds (ie. 12.3s). -1 means to the end of file.
      # * *:DBUnits* (_Boolean_): Are the units of the function in DB scale ? (else they are in a ratio scale).

      include WSK::Common

      # Execute the process
      #
      # Parameters::
      # * *iInputFileName* (_String_): File name we want to apply effects to
      # * *iOutputFileName* (_String_): File name to write
      # * *iTempDir* (_String_): Temporary directory that can be used
      # * *iParams* (<em>map<Symbol,Object></em>): Parameters
      def execut