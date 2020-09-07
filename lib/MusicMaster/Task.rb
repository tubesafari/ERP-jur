# Make prerequisites re-evaluated when changed
module Rake
  class Task

    # Data stored in the task itself, built during its invocation.
    # Useful to represent targets having data not stored in a file.
    attr_accessor :data

    # Keep original method
    alias :invoke_prerequisites_ORG :invoke_prerequisites
    # Rewrite it
    def invoke_prerequ