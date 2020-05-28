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
      return '[--name <Deli