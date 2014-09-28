require 'optparse'

# Parse options
class Option

  class << self
    def parse(option)

      options = option.split

      ymd = hms = nil
      options.each do |option|
        ymd = option if option =~ /\d{4}-\d{1,2}-\d{1,2}/
        hms = option if option =~ /\d{1,2}:\d{1,2}:\d{1,2}/
      end
      unless ymd.nil? || hms.nil?
        options[options.index(ymd)] = ymd + ' ' + hms
        options.delete_at(options.index(hms))
      end

      opt = OptionParser.new

      opts = {}
      opt.on('-t [VAL]') { |v| opts[:t] = v }
      opt.on('-a [VAL]') { |v| opts[:a] = v }
      opt.on('-n VAL') { |v| opts[:n] = v }
      opt.on('-d VAL') { |v| opts[:d] = v }

      commands = {}
      begin
        opt.permute!(options)

        if options.size > 2
          raise 'Single command only'
        end

        commands[:command] = options
        commands[:options] = opts
      rescue => e
        commands[:error] = 'Invalid command or options'
      end

      return commands
    end
  end

end