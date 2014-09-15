require 'rspec'
require 'chocolate'

describe 'create new model' do
  before {
    @factory = ModelFactory.new('fwrs')
  }

  describe 'create fwrs model' do
    subject { @factory }
    #it { is_expected.to }
  end
end