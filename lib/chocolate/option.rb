require 'optparse'

# Parse options
class Option

  class << self
    def parse(option)

      options = option.split

      opt = OptionParser.new

      opts = {}
      opt.on('-t VAL') { |v| opts[:t] = v }
      opt.on('-m VAL') { |v| opts[:m] = v }

      commands = {}
      begin
        opt.permute!(options)

        if options.size > 1
          raise 'Single command only'
        end

        commands[:comand] = options
        commands[:options] = opts
      rescue => e
        commands[:error] = 'Invalid command or options'
      end

      return commands
    end
  end

end