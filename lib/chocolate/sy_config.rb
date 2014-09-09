require 'psych'

class SyConfig

  def initialize(type)
    @type = type
  end

  def load
    yml = nil
    File.open('../config/config.yml', 'r') do |file|
      yml = Psych.load(file)
    end

    return yml[@type]
  end

end