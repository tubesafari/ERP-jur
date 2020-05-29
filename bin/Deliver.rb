#!env ruby

require 'MusicMaster/Launcher'

module MusicMaster

  class Deliver < Launcher

    protected

    # Give additional command line options banner
    #
    # Return::
    # * _String_: Options banner
    def getOptionsBanner
      return '[--name <DeliverableName>]*'
    end

    # Complete options with the specific ones of this binary
    #
    # Parameters::
    # * *ioOptionParser* (_OptionParser_): The options parser to complete
    def completeOptionParser(ioOptionParser)
      @LstDeliverableNames = []
 