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
      return @MusicMasterConf[:Directories][:Wave]
    end

    # Get the directory in which recorded files are analyzed
    #
    # Return::
    # * _String_: Directory to store analysis results of recorded files to
    def getAnalyzedRecordedDir
      return @MusicMasterConf[:Directories][:AnalyzeRecord]
    end

    # Get the directory in which files are cleaned
    #
    # Return::
    # * _String_: Directory to clean files to
    def getCleanedDir
      return @MusicMasterConf[:Directories][:Clean]
    end

    # Get the directory in