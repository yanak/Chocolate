require 'psych'

class SyConfig

  def initialize(type)
    @type = type
  end

  def load
    yml = nil
    File.open(File.expand_path('../../../config/config.yml', __FILE__), 'r') do |file|
      yml = Psych.load(file)
    end

    return yml[@type]
  end

end