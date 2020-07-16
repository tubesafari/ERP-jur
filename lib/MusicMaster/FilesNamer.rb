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
      return @MusicMasterConf[:Directories][:Deliver]
    end

    # Get the recorded file name of a given list of tracks on a given environment
    #
    # Parameters::
    # * *iEnv* (_Symbol_): The environment
    # * *iLstTracks* (<em>list<Integer></em>): The list of tracks being recorded
    # Return::
    # * _String_: Name of the Wave file
    def getRecordedFileName(iEnv, iLstTracks)
      return "#{getRecordedDir}/#{iEnv}.#{iLstTracks.sort.join('.')}.wav"
    end

    # Get the recorded silence file name on a given recording environment
    #
    # Parameters::
    # * *iEnv* (_Symbol_): The environment
    # Return::
    # * _String_: Name of the Wave file
    def getRecordedSilenceFileName(iEnv)
      return "#{getRecordedDir}/#{iEnv}.Silence.wav"
    end

    # Get the recorded calibration file name, recording from a recording environment in order to be compared later with a reference environment.
    #
    # Parameters::
    # * *iEnvReference* (_Symbol_): The reference environment
    # * *iEnvRecording* (_Symbol_): The recording environment
    # Return::
    # * _String_: Name of the Wave file
    def getRecordedCalibrationFileName(iEnvReference, iEnvRecording)
      return "#{getRecordedDir}/Calibration.#{iEnvRecording}.#{iEnvReference}.wav"
    end

    # Get the calibrated recorded file name
    #
    # Parameters::
    # * *iRecordedBaseName* (_String_): Base name of the recorded track
    # Return::
    # * _String_: Name of the Wave file
    def getCalibratedFileName(iRecordedBaseName)
      return "#{getCalibratedDir}/#{iRecordedBaseName}.Calibrated.wav"
    end

    # Get the name of a source wave file
    #
    # Parameters::
    # * *iFileName* (_String_): Name of the Wave file used to generate this source wave file
    # Return::
    # * _String_: Name of the Wave file
    def getWaveSourceFileName(iFileName)
      if (File.exists?(iFileName))
        # Use the original one
        return iFileName
      else
        # We will generate a new one
        return "#{getWaveDir}/#{File.basename(iFileName)}"
      end
    end

    # Get the name of an analysis file taken from a recorded file
    #
    # Parameters::
    # * *iBaseName* (_String_): Base name of the recorded file (without extension)
    # Return::
    # * _String_: The analysis file name
    def getRecordedAnalysisFileName(iBaseName)
      return "#{getAnalyzedRecordedDir}/#{iBaseName}.analyze"
    end

    # Get the name of a FFT profike file taken from a recorded file
    #
    # Parameters::
    # * *iBaseName* (_String_): Base name of the recorded file (without extension)
    # Return::
    # * _String_: The FFT profile file name
    def getRecordedFFTProfileFileName(iBaseName)
      return "#{getAnalyzedRecordedDir}/#{iBaseName}.fftprofile"
    end

    # Get the name of the file generated after removing silences from it.
    #
    # Parameters::
    # * *iBaseName* (_String_): Base name of the file
    # Return::
    # * _String_: The generated file name
