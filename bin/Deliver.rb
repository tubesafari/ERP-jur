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
      ioOptionParser.on( '--name <DeliverableName>', String,
        'Specify the name of the deliverable to produce. Can be used several times. If not specified, all deliverables will be produced.') do |iArg|
        @LstDeliverableNames << iArg
  