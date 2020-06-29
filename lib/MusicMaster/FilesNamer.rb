require 'MusicMaster/Hash'

module MusicMaster

  module FilesNamer

    # Get the directory in which files are recorded
    #
    # Return::
    # * _String_: Directory to record files to
    def getRecordedDir
      return @MusicMasterConf[:Directories][:Record]
    end

    # Get the directory in which static audio files are stored
    #
    # Return::
    # * _String_: Directory to store static audio files to
    def getWaveDir
      return @MusicMasterConf[:Direct