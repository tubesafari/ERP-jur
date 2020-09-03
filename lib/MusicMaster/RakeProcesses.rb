
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
