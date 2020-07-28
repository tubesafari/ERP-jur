module MusicMaster

  module Formats

    class MP3

      # Give the file extension
      #
      # Return::
      # * _String_: The file extension (without .)
      def getFileExt
        return 'mp3'
      end

      # Deliver a file.
      # The delivered file can be a shortcut to the source one.
  