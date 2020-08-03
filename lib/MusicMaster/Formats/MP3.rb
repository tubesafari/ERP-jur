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
      #
      # Parameters::
      # * *iSrcFileName* (_String_): The source file to deliver from
      # * *iDstFileName* (_String_): The destination file to be delivered
      # * *iFormatConf* (<em>map<Symbol,Object></em>): The format configuration
      # * *iMetadata* (<em>map<Symbol,Object></em>): The metadata that can be used while delivering the file
      def deliver(iSrcFileName, iDstFileName, iFormatConf, iMetadata)
        # TODO: Implement it using an external tool, and make regression tes