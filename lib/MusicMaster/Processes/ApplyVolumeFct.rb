require 'WSK/Common'

module MusicMaster

  module Processes

    class ApplyVolumeFct

      # Parameters of this process:
      # * *:Function* (<em>map<Symbol,Object></em>): The function definition
      # * *:Begin* (_String_): Position to apply volume transformation from. Can be specified as a sample number or a float seconds (ie. 12.3s).
      # * *:End* (_String_): Position to apply volume transformation to. Can be specified as a sample number or a float seconds (ie. 12.3s). -1 means to the