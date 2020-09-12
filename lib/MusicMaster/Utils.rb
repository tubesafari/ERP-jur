
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
          lSkip = false
        else
          puts 'Press Enter to continue once done. Type \'s\' to skip it.'
          lSkip = ($stdin.gets.chomp == 's')
        end
        if (lSkip)
          lTryAgain = false
        else
          # Get the recorded file name
          lFileName = @MusicMasterConf[:Record][:RecordedFileGetter].call
          if (!File.exists?(lFileName))
            log_err "File #{lFileName} does not exist. Could not get recorded file."
          else
            log_info "Getting recorded file: #{lFileName} => #{iFileName}"
            FileUtils::mkdir_p(File.dirname(iFileName))
            FileUtils::mv(lFileName, iFileName)
            lTryAgain = false
          end
        end
      end
    end

    # Make an FFT profile of a given wav file, and store the result in the given file name.
    #
    # Parameters::
    # * *iWaveFile* (_String_): The wav file to analyze
    # * *iFFTProfileFile* (_String_): The analysis file to store into
    def fftProfileFile(iWaveFile, iFFTProfileFile)
      lDummyFile = "#{Dir.tmpdir}/MusicMaster/Dummy.wav"
      FileUtils::mkdir_p(File.dirname(lDummyFile))
      wsk(iWaveFile, lDummyFile, 'FFT')
      File.unlink(lDummyFile)
      FileUtils::mkdir_p(File.dirname(iFFTProfileFile))
      FileUtils::mv('fft.result', iFFTProfileFile)
    end

    # Analyze a given wav file, and store the result in the given file name.
    #
    # Parameters::
    # * *iWaveFile* (_String_): The wav file to analyze
    # * *iAnalysisFile* (_String_): The analysis file to store into
    def analyzeFile(iWaveFile, iAnalysisFile)
      lDummyFile = "#{Dir.tmpdir}/MusicMaster/Dummy.wav"
      FileUtils::mkdir_p(File.dirname(lDummyFile))
      wsk(iWaveFile, lDummyFile, 'Analyze')
      File.unlink(lDummyFile)
      FileUtils::mkdir_p(File.dirname(iAnalysisFile))
      FileUtils::mv('analyze.result', iAnalysisFile)
    end

    # Get analysis result
    #
    # Parameters::
    # * *iAnalysisFileName* (_String_): The name of the analysis file
    # Return::
    # * <em>map<Symbol,Object></em>: The analyze result
    def getAnalysis(iAnalysisFileName)
      rResult = nil

      if (@Cache[:Analysis][iAnalysisFileName] == nil)
        File.open(iAnalysisFileName, 'rb') do |iFile|
          rResult = Marshal.load(iFile.read)
        end
        @Cache[:Analysis][iAnalysisFileName] = rResult
      else
        rResult = @Cache[:Analysis][iAnalysisFileName]
      end

      return rResult
    end

    # Get DC offsets out of an analysis file
    #
    # Parameters::
    # * *iAnalyzeRecordedFileName* (_String_): Name of the file containing analysis
    # Return::
    # * _Boolean_: Is there an offset ?
    # * <em>list<Float></em>: The DC offsets, per channel
    def getDCOffsets(iAnalyzeRecordedFileName)
      rOffset = false
      rDCOffsets = []

      if (@Cache[:DCOffsets][iAnalyzeRecordedFileName] == nil)
        lAnalyze = getAnalysis(iAnalyzeRecordedFileName)
        lAnalyze[:MoyValues].each do |iMoyValue|
          lDCOffset = iMoyValue.round
          rDCOffsets << lDCOffset
          if (lDCOffset != 0)
            rOffset = true
          end
        end
        @Cache[:DCOffsets][iAnalyzeRecordedFileName] = [ rOffset, rDCOffsets ]
      else
        rOffset, rDCOffsets = @Cache[:DCOffsets][iAnalyzeRecordedFileName]
      end

      return rOffset, rDCOffsets
    end

    # Get average RMS value from an analysis file
    #
    # Parameters::
    # * *iAnalysisFileName* (_String_): Name of the analysis file
    # Return::
    # * _Float_: The average RMS value
    def getRMSValue(iAnalysisFileName)
      rRMSValue = nil

      if (@Cache[:RMSValues][iAnalysisFileName] == nil)
        lAnalysis = getAnalysis(iAnalysisFileName)
        rRMSValue = lAnalysis[:RMSValues].inject{ |iSum, iValue| next (iSum + iValue) } / lAnalysis[:RMSValues].size
        @Cache[:RMSValues][iAnalysisFileName] = rRMSValue
      else
        rRMSValue = @Cache[:RMSValues][iAnalysisFileName]
      end

      return rRMSValue
    end

    # Get signal thresholds, without DC offsets, from an analysis file
    #
    # Parameters::
    # * *iAnalysisFileName* (_String_): Name of the file containing analysis
    # * *iOptions* (<em>map<Symbol,Object></em>): Additional options [optional = {}]
    #   * *:margin* (_Float_): The margin to be added, in terms of fraction of the maximal signal value [optional = 0.0]
    # Return::
    # * <em>list< [Integer,Integer] ></em>: The [min,max] values, per channel
    def getThresholds(iAnalysisFileName, iOptions = {})
      rThresholds = []

      if (@Cache[:Thresholds][iAnalysisFileName] == nil)
        # Get silence thresholds from the silence file
        lSilenceAnalyze = getAnalysis(iAnalysisFileName)
        # Compute the DC offsets
        lSilenceDCOffsets = lSilenceAnalyze[:MoyValues].map { |iValue| iValue.round }
        lMargin = iOptions[:margin] || 0.0
        lSilenceAnalyze[:MaxValues].each_with_index do |iMaxValue, iIdxChannel|
          # Remove silence DC Offset
          lCorrectedMinValue = lSilenceAnalyze[:MinValues][iIdxChannel] - lSilenceDCOffsets[iIdxChannel]
          lCorrectedMaxValue = iMaxValue - lSilenceDCOffsets[iIdxChannel]
          # Compute the silence threshold by adding the margin
          rThresholds << [(lCorrectedMinValue-lCorrectedMinValue.abs*lMargin).to_i, (lCorrectedMaxValue+lCorrectedMaxValue.abs*lMargin).to_i]
        end
        @Cache[:Thresholds][iAnalysisFileName] = rThresholds
      else
        rThresholds = @Cache[:Thresholds][iAnalysisFileName]
      end

      return rThresholds
    end

    # Shift thresholds by a given DC offset.
    #
    # Parameters::
    # * *iThresholds* (<em>list< [Integer,Integer] ></em>): The thresholds to shift
    # * *iDCOffsets* (<em>list<Integer></em>): The DC offsets
    # Return::
    # * <em>list< [Integer,Integer] ></em>: The shifted thresholds
    def shiftThresholdsByDCOffset(iThresholds, iDCOffsets)
      rCorrectedThresholds = []

      # Compute the silence thresholds with DC offset applied
      iThresholds.each_with_index do |iThresholdInfo, iIdxChannel|
        lChannelDCOffset = iDCOffsets[iIdxChannel]
        rCorrectedThresholds << iThresholdInfo.map { |iValue| iValue + lChannelDCOffset }
      end

      return rCorrectedThresholds
    end

    # The groups of processes that can be optimized, and their corresponding optimization methods
    # They are sorted by importance: first ones will have greater priority
    # Here are the symbols used for each group:
    # * *:OptimizeProc* (_Proc_): The code called to optimize a group. It is called only for groups containing all processes from the group key, and including no other processes. Only for groups strictly larger than 1 element.
    #   Parameters::
    #   * *iLstProcesses* (<em>list<map<Symbol,Object>></em>): List of processes to optimize
    #   Return::
    #   * <em>list<map<Symbol,Object>></em>: List of optimized processes. Can be empty to delete them, or nil to not optimize them.
    OPTIM_GROUPS = [
      [ [ 'VolCorrection' ],
        {
          :OptimizeProc => Proc.new do |iLstProcesses|
            rOptimizedProcesses = []

            lRatio = 0.0
            iLstProcesses.each do |iProcessInfo|
              lRatio += readStrRatio(iProcessInfo[:Factor])
            end
            if (lRatio != 0)
              # Replace the serie with just 1 volume correction
              rOptimizedProcesses = [ {
                :Name => 'VolCorrection',
                :Factor => "#{lRatio}db"
              } ]
            end

            next rOptimizedProcesses
          end
        }
      ],
      [ [ 'DCShifter' ],
        {
          :OptimizeProc => Proc.new do |iLstProcesses|
            rOptimizedProcesses = []

            lDCOffset = 0
            iLstProcesses.each do |iProcessInfo|
              lDCOffset += iProcessInfo[:Offset]
            end
            if (lDCOffset != 0)
              # Replace the serie with just 1 DC offset
              rOptimizedProcesses = [ {
                :Name => 'DCShifter',
                :Offset => lDCOffset
              } ]
            end

            next rOptimizedProcesses
          end
        }
      ]
    ]
    # Activate debug log for this method only
    OPTIM_DEBUG = false
    # Optimize a list of processes.
    # Delete useless ones or ones that cancel themselves.
    #
    # Parameters::
    # * *iLstProcesses* (<em>list<map<Symbol,Object>></em>): List of processes
    # Return::
    # * <em>list<map<Symbol,Object>></em>: The optimized list of processes
    def optimizeProcesses(iLstProcesses)
      rNewLstProcesses = []

      lModified = true
      rNewLstProcesses = iLstProcesses
      while (lModified)
        # rNewLstProcesses contains the current list
        log_debug "[Optimize]: ========== Launch optimization for processes list: #{rNewLstProcesses.inspect}" if OPTIM_DEBUG
        lLstCurrentProcesses = rNewLstProcesses
        rNewLstProcesses = []
        lModified = false

        # The list of all possible group keys that can be used for optimizations
        # list< [ list<String>, map<Symbol,Object> ] >
        lCurrentMatchingGroups = nil
        lIdxGroupBegin = nil
        lIdxProcess = 0
        while (lIdxProcess < lLstCurrentProcesses.size)
          lProcessInfo = lLstCurrentProcesses[lIdxProcess]
          log_debug "[Optimize]: ===== Process Index: #{lIdxProcess} - Process: #{lProcessInfo.inspect} - Process group begin: #{lIdxGroupBegin.inspect} - Current matching groups: #{lCurrentMatchingGroups.inspect} - New processes list: #{rNewLstProcesses.inspect}" if OPTIM_DEBUG
          if (lIdxGroupBegin == nil)
            # We can begin grouping
            lCurrentMatchingGroups = []
            OPTIM_GROUPS.each do |iGroupInfo|
              if (iGroupInfo[0].include?(lProcessInfo[:Name]))
                # This group key can begin a new group
                lCurrentMatchingGroups << iGroupInfo
              end
            end
            if (lCurrentMatchingGroups.empty?)
              # We can't do anything with this process
              rNewLstProcesses << lProcessInfo