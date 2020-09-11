
require 'pp'
require 'tmpdir'

module MusicMaster

  module Utils

    # Initialize variables used by utils
    def initialize_Utils
      # A little cache
      # map< Symbol, Object >
      # * *:Analysis* (<em>map<String,Object></em>): Analysis object, per analysis file name
      # * *:DCOffsets* (<em>map<String,list<Float>></em>): Channels DC offsets, per analysis file name
      # * *:RMSValues* (<em>map<String,Float></em>): The average RMS values, per analysis file name
      # * *:Thresholds* (<em>map<String,list< [Integer,Integer] >></em>): List of [min,max] thresholds per channel, per analysis file name
      @Cache = {
        :Analysis => {},
        :DCOffsets => {},
        :RMSValues => {},
        :Thresholds => {}
      }
    end

    # Record into a given file
    #
    # Parameters::
    # * *iFileName* (_String_): File name to record into
    # * *iAlreadyPrepared* (_Boolean_): Is the file to be recorded already prepared ? [optional = false]
    def record(iFileName, iAlreadyPrepared = false)
      lTryAgain = true
      if (File.exists?(iFileName))
        puts "File \"#{iFileName}\" already exists. Overwrite ? ['y' = yes]"
        lTryAgain = ($stdin.gets.chomp == 'y')
      end
      while (lTryAgain)
        puts "Record file \"#{iFileName}\""
        lSkip = nil
        if (iAlreadyPrepared)