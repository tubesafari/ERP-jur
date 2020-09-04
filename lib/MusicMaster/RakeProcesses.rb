
gem 'rake', '>= 0.9'
require 'rake'

require 'rUtilAnts/Platform'
RUtilAnts::Platform.install_platform_on_object
require 'rUtilAnts/Misc'
RUtilAnts::Misc.install_misc_on_object
require 'MusicMaster/Symbol'
require 'MusicMaster/Task'

module MusicMaster

  module RakeProcesses

    class UnknownTrackIDError < RuntimeError
    end

    include Rake::DSL

    # Initialize variables used by rake processes
    #
    # Parameters::
    # * *iOptions* (<em>map<Symbol,Object></em>): First set of options [optional = {}]
    def initialize_RakeProcesses(iOptions = {})
      # The context: this will be shared across Rake tasks and this code.
      # map< Symbol, Object >
      # * *:EnvsToCalibrate* (<em>map< [Symbol,Symbol],nil ></em>): The set of environments pairs to calibrate
      # * *:CleanFiles* (<em>map<String,map<Symbol,Object>></em>: Data associated to a recorded file that will be cleaned, per recorded file base name (without extension):
      #   * *:FramedFileName* (_String_): Name of the recorded file once framed
      #   * *:DCRemovedFileName* (_String_): Name of the file without DC offset
      #   * *:NoiseGatedFileName* (_String_): Name of the file with noise gate applied
      #   * *:SilenceAnalysisFileName* (_String_): Name of the file containing analysis of the corresponding silence recording
      #   * *:SilenceFFTProfileFileName* (_String_): Name of the file containing FFT profile of the corresponding silence recording
      # * *:RakeSetupFor_GenerateSourceFiles* (_Boolean_): Have the rules for GenerateSourceFiles been created ?
      # * *:RakeSetupFor_CleanRecordings* (_Boolean_): Have the rules for CleanRecordings been created ?
      # * *:RakeSetupFor_CalibrateRecordings* (_Boolean_): Have the rules for CalibrateRecordings been created ?
      # * *:RakeSetupFor_ProcessSourceFiles* (_Boolean_): Have the rules for ProcessSourceFiles been created ?
      # * *:RakeSetupFor_Mix* (_Boolean_): Have the rules for Mix been created ?
      # * *:Calibrate* (<em>map<String,map<Symbol,Object>></em>): Data associated to a calibrated file, per recorded file base name (without extension):
      #   * *:FinalTask* (_Symbol_): Name of the final calibration task
      #   * *:CalibratedFileName* (_String_): Name of the calibrated file
      # * *:CalibrationAnalysisFiles* (<em>map< [Symbol,Symbol],String ></em>): Name of the calibration analysis files, per environment pair [ReferenceEnv, RecordingEnv]
      # * *:Processes* (<em>map<String,map<Symbol,Object>></em>): Data associated to a process chain, per recorded file base name (without extension):
      #   * *:LstProcesses* (<em>list<map<Symbol,Object>></em>): List of processes to apply to this recording
      #   * *:FinalTask* (_Symbol_): Name of the final process task
      # * *:WaveProcesses* (<em>map<String,map<Symbol,Object>></em>): Data associated to a process chain, per Wave name (from the config file):
      #   * *:LstProcesses* (<em>list<map<Symbol,Object>></em>): List of processes to apply to this Wave file
      #   * *:FinalTask* (_Symbol_): Name of the final process task
      # * *:RecordedFilesPrepared* (_Boolean_): Recorded files are already prepared: no need to wait for user input while recording.
      # * *:LstEnvToRecord* (<em>list<Symbol></em>): The list of recording environments to record. An empty list means all environments.
      # * *:LstMixNames* (_String_): Names of the mix to produce. Can be empty to produce all mixes.
      # * *:LstDeliverNames* (_String_): Names of the deliverables to produce. Can be empty to produce all deliverables.
      # * *:FinalMixSources* (<em>map<Object,Symbol></em>): List of all tasks defining source files, per mix TrackID
      # * *:DeliverableConf* (<em>map<String,[map<Symbol,Object>,map<Symbol,Object>]></em>): The deliverable information, per deliverable file name: [FormatConfig, Metadata]
      # * *:Deliverables* (<em>map<String,map<Symbol,Object>></em>): Data associated to a deliverable, per deliverable name (from the config file):
      #   * *:FileName* (_String_): The real deliverable file name
      @Context = {
        :EnvsToCalibrate => {},
        :CleanFiles => {},
        :RakeSetupFor_GenerateSourceFiles => false,
        :RakeSetupFor_CleanRecordings => false,
        :RakeSetupFor_CalibrateRecordings => false,
        :RakeSetupFor_ProcessSourceFiles => false,
        :Calibrate => {},
        :CalibrationAnalysisFiles => {},
        :Processes => {},
        :WaveProcesses => {},
        :RecordedFilesPrepared => false,
        :LstEnvToRecord => [],
        :LstMixNames => [],
        :LstDeliverableNames => [],
        :FinalMixSources => {},
        :DeliverableConf => {},
        :Deliverables => {}
      }.merge(iOptions)
    end

    # Display rake tasks
    # This is useful for debugging purposes
    def displayRakeTasks
      Rake.application.tasks.each do |iTask|
        log_info   "+-#{iTask.name}: #{iTask.comment}"
        iTask.prerequisites.each do |iPrerequisiteTaskName|
          log_info "| +-#{iPrerequisiteTaskName}"
        end
        log_info   '|'
      end
    end

    # Generate rake targets for generating source files
    def generateRakeFor_GenerateSourceFiles
      lLstGlobalRecordTasks = []

      # 1. Recordings
      lRecordingsConf = @RecordConf[:Recordings]
      if (lRecordingsConf != nil)
        # Generate recordings rules
        # Gather the recording environments and their respective file names to produce
        # map< Symbol, list< String > >
        lRecordings = {}
        lTracksConf = lRecordingsConf[:Tracks]
        if (lTracksConf != nil)
          lTracksConf.each do |iLstTracks, iRecordingConf|
            lEnv = iRecordingConf[:Env]
            lRecordedFileName = getRecordedFileName(lEnv, iLstTracks)

            desc "Raw recording of tracks #{iLstTracks.sort.join(', ')} in recording environment #{lEnv}"
            file lRecordedFileName do |iTask|
              # Raw recording task
              record(iTask.name, @Context[:RecordedFilesPrepared])
            end

            if (lRecordings[lEnv] == nil)
              lRecordings[lEnv] = []
            end
            lRecordings[lEnv] << lRecordedFileName
            # If there is a need of calibration, record also the calibration files
            if (iRecordingConf[:CalibrateWithEnv] != nil)
              lReferenceEnv = iRecordingConf[:CalibrateWithEnv]
              [
                [ lReferenceEnv, lEnv ],
                [ lEnv, lReferenceEnv ]
              ].each do |iEnvPair|
                iRefEnv, iRecEnv = iEnvPair
                lCalibrationFileName = getRecordedCalibrationFileName(iRefEnv, iRecEnv)
                if (lRecordings[iRecEnv] == nil)
                  lRecordings[iRecEnv] = []
                end
                if (!lRecordings[iRecEnv].include?(lCalibrationFileName))

                  desc "Calibration recording in recording environment #{iRecEnv} to be compared with reference environment #{iRefEnv}"
                  file lCalibrationFileName do |iTask|
                    record(iTask.name, @Context[:RecordedFilesPrepared])
                  end

                  lRecordings[iRecEnv] << lCalibrationFileName
                end
              end
              @Context[:EnvsToCalibrate][[ lReferenceEnv, lEnv ].sort] = nil
            end
          end
        end
        # Make the task recording in the correct order
        lSortedEnv = lRecordingsConf[:EnvRecordingOrder] || []
        lRecordings.sort do
          |iElem1, iElem2|
          if (iElem2[1].size == iElem1[1].size)
            next iElem1[0] <=> iElem2[0]
          else
            next iElem2[1].size <=> iElem1[1].size
          end
        end.each do |iElem|
          if (!lSortedEnv.include?(iElem[0]))
            lSortedEnv << iElem[0]
          end
        end
        lLstTasks = []
        lSortedEnv.each do |iEnv|
          lLstFiles = lRecordings[iEnv]
          if (lLstFiles != nil)
            # Record a silence file
            lSilenceFile = getRecordedSilenceFileName(iEnv)

            desc "Record silence file for recording environment #{iEnv}"
            file lSilenceFile do |iTask|
              # Raw recording task
              record(iTask.name, @Context[:RecordedFilesPrepared])
            end

            lSymTask = "Record_#{iEnv}".to_sym

            desc "Record all files for recording environment #{iEnv}"
            task lSymTask => lLstFiles + [lSilenceFile]

            lLstTasks << lSymTask if (@Context[:LstEnvToRecord].empty?) or (@Context[:LstEnvToRecord].include?(iEnv))
          end
        end

        desc 'Record all files'
        task :Record => lLstTasks

        lLstGlobalRecordTasks << :Record
      end

      # 2. Wave files
      lWaveFilesConf = @RecordConf[:WaveFiles]
      if (lWaveFilesConf != nil)
        # Generate wave files rules
        lLstWaveFiles = []
        lWaveFilesConf[:FilesList].map { |iFileInfo| iFileInfo[:Name] }.each do |iFileName|
          lWaveFileName = getWaveSourceFileName(iFileName)
          if (!File.exists?(iFileName))

            desc "Generate wave file #{iFileName}"
            file lWaveFileName do |iTask|
              puts "Create Wave file #{iTask.name}, and press Enter when done."
              $stdin.gets
            end

          end
          lLstWaveFiles << lWaveFileName
        end

        desc 'Generate all wave files'
        task :GenerateWaveFiles => lLstWaveFiles

        lLstGlobalRecordTasks << :GenerateWaveFiles
      end

      desc 'Generate source files (both recording and Wave files)'
      task :GenerateSourceFiles => lLstGlobalRecordTasks

      @Context[:RakeSetupFor_GenerateSourceFiles] = true
    end

    # Generate rake targets for cleaning recorded files
    def generateRakeFor_CleanRecordings
      if (!@Context[:RakeSetupFor_GenerateSourceFiles])
        generateRakeFor_GenerateSourceFiles
      end

      # List of cleaning tasks
      # list< Symbol >
      lLstCleanTasks = []
      lRecordingsConf = @RecordConf[:Recordings]
      if (lRecordingsConf != nil)
        lTracksConf = lRecordingsConf[:Tracks]
        if (lTracksConf != nil)
          # Look for recorded files
          lTracksConf.each do |iLstTracks, iRecordingConf|
            lEnv = iRecordingConf[:Env]
            lRecordedFileName = getRecordedFileName(lEnv, iLstTracks)
            lRecordedBaseName = File.basename(lRecordedFileName[0..-5])
            # Clean the recorded file itself
            lLstCleanTasks << generateRakeForCleaningRecordedFile(lRecordedBaseName, lEnv)
          end
          # Look for calibration files
          @Context[:EnvsToCalibrate].each do |iEnvToCalibratePair, iNil|
            iEnv1, iEnv2 = iEnvToCalibratePair
            # Read the cutting values if any from the conf
            lCutInfo = nil
            if (lRecordingsConf[:EnvCalibration] != nil)
              lRecordingsConf[:EnvCalibration].each do |iEnvPair, iCalibrationInfo|
                if (iEnvPair.sort == iEnvToCalibratePair)
                  # Found it
                  lCutInfo = iCalibrationInfo[:CompareCuts]
                  break
                end
              end
            end
            # Clean the calibration files
            lReferenceFileName = getRecordedCalibrationFileName(iEnv1, iEnv2)
            lLstCleanTasks << generateRakeForCleaningRecordedFile(File.basename(lReferenceFileName)[0..-5], iEnv2, lCutInfo)
            lRecordingFileName = getRecordedCalibrationFileName(iEnv2, iEnv1)
            lLstCleanTasks << generateRakeForCleaningRecordedFile(File.basename(lRecordingFileName)[0..-5], iEnv1, lCutInfo)
          end
        end
      end

      desc 'Clean all recorded files: remove silences, cut them, remove DC offset and apply noise gate'
      task :CleanRecordings => lLstCleanTasks.sort.uniq

      @Context[:RakeSetupFor_CleanRecordings] = true
    end

    # Generate rake targets for calibrating recorded files
    def generateRakeFor_CalibrateRecordings
      if (!@Context[:RakeSetupFor_CleanRecordings])
        generateRakeFor_CleanRecordings
      end

      # List of calibrating tasks
      # list< Symbol >
      lLstCalibrateTasks = []
      lRecordingsConf = @RecordConf[:Recordings]
      if (lRecordingsConf != nil)
        lTracksConf = lRecordingsConf[:Tracks]
        if (lTracksConf != nil)
          # Generate analysis files for calibration files
          @Context[:EnvsToCalibrate].each do |iEnvToCalibratePair, iNil|
            [
              [ iEnvToCalibratePair[0], iEnvToCalibratePair[1] ],
              [ iEnvToCalibratePair[1], iEnvToCalibratePair[0] ]
            ].each do |iEnvPair|
              iEnv1, iEnv2 = iEnvPair
              lCalibrationFileName = getRecordedCalibrationFileName(iEnv1, iEnv2)
              lNoiseGatedFileName = @Context[:CleanFiles][File.basename(lCalibrationFileName)[0..-5]][:NoiseGatedFileName]
              lAnalysisFileName = getRecordedAnalysisFileName(File.basename(lNoiseGatedFileName)[0..-5])
              @Context[:CalibrationAnalysisFiles][iEnvPair] = lAnalysisFileName

              desc "Generate analysis for framed calibration file #{lNoiseGatedFileName}"
              file lAnalysisFileName => lNoiseGatedFileName do |iTask|
                analyzeFile(iTask.prerequisites[0], iTask.name)
              end

            end
          end

          # Generate calibrated files
          lTracksConf.each do |iLstTracks, iRecordingConf|
            if (iRecordingConf[:CalibrateWithEnv] != nil)
              # Need calibration
              lRecEnv = iRecordingConf[:Env]
              lRefEnv = iRecordingConf[:CalibrateWithEnv]
              lRecordedBaseName = File.basename(getRecordedFileName(lRecEnv, iLstTracks))[0..-5]
              # Create the data target that stores the comparison of analysis files for calibration
              lCalibrationInfoTarget = "#{lRecordedBaseName}.Calibration.info".to_sym

              desc "Compare the analysis of calibration files for recording #{lRecordedBaseName}"
              task lCalibrationInfoTarget => [
                @Context[:CalibrationAnalysisFiles][[lRefEnv,lRecEnv]],
                @Context[:CalibrationAnalysisFiles][[lRecEnv,lRefEnv]]
              ] do |iTask|
                iRecordingCalibrationAnalysisFileName, iReferenceCalibrationAnalysisFileName = iTask.prerequisites
                # Compute the distance between the 2 average RMS values
                lRMSReference = getRMSValue(iReferenceCalibrationAnalysisFileName)
                lRMSRecording = getRMSValue(iRecordingCalibrationAnalysisFileName)
                log_info "Reference environment #{lRefEnv} - RMS: #{lRMSReference}"
                log_info "Recording environment #{lRecEnv} - RMS: #{lRMSRecording}"
                iTask.data = {
                  :RMSReference => lRMSReference,
                  :RMSRecording => lRMSRecording,
                  :MaxValue => getAnalysis(iRecordingCalibrationAnalysisFileName)[:MinPossibleValue].abs
                }
              end

              # Create the dependency task
              lDependenciesTask = "Dependencies_Calibration_#{lRecordedBaseName}".to_sym

              desc "Compute dependencies to know if we need to calibrate tracks [#{iLstTracks.join(', ')}] recording."
              task lDependenciesTask => lCalibrationInfoTarget do |iTask|
                lCalibrationInfo = Rake::Task[iTask.prerequisites.first].data
                # If the RMS values are different, we need to generate the calibrated file
                lRecordedBaseName2 = iTask.name.match(/^Dependencies_Calibration_(.*)$/)[1]
                lCalibrateContext = @Context[:Calibrate][lRecordedBaseName2]
                lLstPrerequisitesFinalTask = [iTask.name]
                if (lCalibrationInfo[:RMSRecording] != lCalibrationInfo[:RMSReference])
                  # Make the final task depend on the calibrated file
                  lLstPrerequisitesFinalTask << lCalibrateContext[:CalibratedFileName]
                  # Create the target that will generate the calibrated file.

                  desc "Generate calibrated recording for #{lRecordedBaseName2}"
                  file @Context[:Calibrate][lRecordedBaseName2][:CalibratedFileName] => [
                    @Context[:CleanFiles][lRecordedBaseName2][:NoiseGatedFileName],
                    lCalibrationInfoTarget
                  ] do |iTask2|
                    iRecordedFileName, iCalibrationInfoTarget = iTask2.prerequisites
                    lCalibrationInfo = Rake::Task[iCalibrationInfoTarget].data
                    # If the Recording is louder, apply a volume reduction
                    if (lCalibrationInfo[:RMSRecording] < lCalibrationInfo[:RMSReference])
                      # Here we are loosing quality: we need to increase the recording volume.
                      # Notify the user about it.
                      lDBValue, lPCValue = val2db(lCalibrationInfo[:RMSReference]-lCalibrationInfo[:RMSRecording], lCalibrationInfo[:MaxValue])
                      log_warn "Tracks [#{iLstTracks.join(', ')}] should be recorded louder (at least #{lDBValue} db <=> #{lPCValue} %)."
                    end
                    wsk(iRecordedFileName, iTask2.name, 'Multiply', "--coeff \"#{lCalibrationInfo[:RMSReference]}/#{lCalibrationInfo[:RMSRecording]}\"")
                  end

                end
                Rake::Task[lCalibrateContext[:FinalTask]].prerequisites.replace(lLstPrerequisitesFinalTask)
              end

              # Make the final task depend on this dependency task
              lCalibrateFinalTask = "Calibrate_#{iLstTracks.join('_')}".to_sym
              lLstCalibrateTasks << lCalibrateFinalTask
              @Context[:Calibrate][lRecordedBaseName] = {
                :FinalTask => lCalibrateFinalTask,
                :CalibratedFileName => getCalibratedFileName(lRecordedBaseName)
              }

              desc "Calibrate tracks [#{iLstTracks.join(', ')}] recording."
              task lCalibrateFinalTask => lDependenciesTask

            end
          end

        end
      end
      # Generate global task

      desc 'Calibrate recordings needing it'
      task :CalibrateRecordings => lLstCalibrateTasks

      @Context[:RakeSetupFor_CalibrateRecordings] = true
    end

    # Generate rake targets for processing source files
    def generateRakeFor_ProcessSourceFiles
      if (!@Context[:RakeSetupFor_CalibrateRecordings])
        generateRakeFor_CalibrateRecordings
      end

      # List of process tasks
      # list< Symbol >
      lLstProcessTasks = []

      # 1. Handle recordings
      lRecordingsConf = @RecordConf[:Recordings]
      if (lRecordingsConf != nil)
        # Read global processes and environment processes to be applied before and after recordings
        lGlobalProcesses_Before = lRecordingsConf[:GlobalProcesses_Before] || []
        lGlobalProcesses_After = lRecordingsConf[:GlobalProcesses_After] || []
        lEnvProcesses_Before = lRecordingsConf[:EnvProcesses_Before] || {}
        lEnvProcesses_After = lRecordingsConf[:EnvProcesses_After] || {}
        lTracksConf = lRecordingsConf[:Tracks]
        if (lTracksConf != nil)
          lTracksConf.each do |iLstTracks, iRecordingConf|
            lRecEnv = iRecordingConf[:Env]
            # Compute the list of processes to apply
            lEnvProcesses_RecordingBefore = lEnvProcesses_Before[lRecEnv] || []
            lEnvProcesses_RecordingAfter = lEnvProcesses_After[lRecEnv] || []
            lRecordingProcesses = iRecordingConf[:Processes] || []
            # Optimize the list
            lLstProcesses = optimizeProcesses(lGlobalProcesses_Before + lEnvProcesses_RecordingBefore + lRecordingProcesses + lEnvProcesses_RecordingAfter + lGlobalProcesses_After)
            # Get the file name to apply processes to
            lRecordedBaseName = File.basename(getRecordedFileName(lRecEnv, iLstTracks))[0..-5]
            # Create the target that gives the name of the final wave file, and make it depend on the Calibration.Info target only if calibration might be needed
            lPrerequisites = []
            lPrerequisites << "#{lRecordedBaseName}.Calibration.info".to_sym if (iRecordingConf[:CalibrateWithEnv] != nil)
            lFinalBeforeMixTarget = "FinalBeforeMix_Recording_#{lRecordedBaseName}".to_sym

            desc "Get final wave file name for recording #{lRecordedBaseName}"
            task lFinalBeforeMixTarget => lPrerequisites do |iTask|
              lRecordedBaseName2 = iTask.name.match(/^FinalBeforeMix_Recording_(.*)$/)[1]
              # Get the name of the file that may be processed
              # Set the cleaned file as a default
              lFileNameToProcess = getNoiseGateFileName(lRecordedBaseName2)
              if (!iTask.prerequisites.empty?)
                lCalibrationInfo = Rake::Task[iTask.prerequisites.first].data
                if (lCalibrationInfo[:RMSReference] != lCalibrationInfo[:RMSRecording])
                  # Apply processes on the calibrated file
                  lFileNameToProcess = getCalibratedFileName(lRecordedBaseName2)
                end
              end
              # By default, the final name is the one to be processed
              lFinalFileName = lFileNameToProcess
              # Get the list of processes from the context
              if (@Context[:Processes][lRecordedBaseName2] != nil)
                # Processing has to be performed
                # Now generate the whole branch of targets to process the choosen file
                lFinalFileName = generateRakeForProcesses(@Context[:Processes][lRecordedBaseName2][:LstProcesses], lFileNameToProcess, getProcessesRecordDir)
              end
              iTask.data = {
                :FileName => lFinalFileName
              }
            end

            if (!lLstProcesses.empty?)
              # Generate the Dependencies task, and make it depend on the target creating the processing chain
              lDependenciesTask = "Dependencies_ProcessRecord_#{lRecordedBaseName}".to_sym