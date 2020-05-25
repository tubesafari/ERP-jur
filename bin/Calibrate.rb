#!env ruby

require 'MusicMaster/Launcher'

module MusicMaster

  class Calibrate < Launcher

    protected

    # Give additional command line options banner
    #
    # Return::
    # * _String_: Options banner
    def getOptionsBanner
      return ''
    end

    # Complete options with the specific ones of this binary
    #
    # Parameters::
    # * *ioOptionParser* (_OptionParser_): The options parser to complete
    def completeOptionParser(ioOptionParser)
    end

    # Check configuration.
    #
    # Parameters::
    # * *iConf* (<em>map<Symbol,Object></em>): The configuration
    # Return::
    # * _Exception_