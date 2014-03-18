# Logging wrapper class. Facilitates variable number of args to allow single call for separate log lines.
# Sample usage (logs two lines in log file):
#   Log.warn('something went wrong', e.message)
class Log
  class << self
    %w(error warn debug info fatal unknown).each do |meth|
      define_method(meth) { |*args| log(meth, *args) }
    end

    private
    def log(level, *args)
      args.each { |arg| Rails.logger.send(level, arg) }
    end
  end
end
