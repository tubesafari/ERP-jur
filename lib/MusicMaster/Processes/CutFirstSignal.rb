module MusicMaster

  module Processes

    class CutFirstSignal

      # Parameters of this process:
      # * *:SilenceMin* (_String_): The minimal duration a silent part must have to be considered as splitting the first non-silent signal from the rest of the audio (either in seconds or in samples)

      # Execute the process
      #
      # Parameters::
      # * *iInputFileName* (_Stri