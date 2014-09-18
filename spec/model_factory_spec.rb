require 'rspec'
require 'chocolate'

describe 'Fwrs master' do
  before {
    @factory = Model::FwrsFactory.new
    @model = @factory.create
  }

  describe 'find feature' do
    subject { @model.find_feature.pop }
    it { is_expected.to have_key(:id)}
  end
end