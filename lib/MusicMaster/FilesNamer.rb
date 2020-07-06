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

    # Get the directory in which files are calibrated
    #
    # Return::
    # * _String_: Directory to calibrate files to
    def getCalibratedDir
      return @MusicMasterConf[:Directories][:Calibrate]
    end

    # Get the directory in which Wave files are processed
    #
    # Return::
    # * _String_: Directory to process files to
    def getProcessesWaveDir
      return @MusicMasterConf[:Directories][:ProcessWave]
    end

    # Get the directory in which recorded files are processed
    #
    # Return::
    # * _String_: Directory to process files to
    def getProcessesRecordDir
      return @MusicMasterConf[:Directories][:ProcessRecord]
    end

    # Get the directory in which mix files are processed
    #
    # Return::
    # * _String_: Directory to mix files to
    def getMixDir
      return @MusicMasterConf[:Directories][:Mix]
    end

    # Get the directory in which final mix files are linked
    #
    # Return::
    # * _String_: Directory storing links to final mix files
    def getFinalMixDir
      return @MusicMasterConf[:Directories][:FinalMix]
    end

    # Get the directory in which files are delivered
    #
    # Return::
    # * _String_: Directory to deliver files to
    def getDeliverDir
      return @MusicMasterCon