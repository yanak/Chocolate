require 'rspec'
require 'chocolate/sy_config'

describe 'Database config behaviour' do
  before {
    @config = SyConfig.new('database')
  }

  describe 'load database config' do
    subject { @config.load }
    it { is_expected.to have_key('host') }
    it { is_expected.to have_key('user') }
    it { is_expected.to have_key('password') }
    it { is_expected.to have_key('db_name')}
  end

end

describe 'User info config behaviour' do
  before {
    @config = SyConfig.new('user_info')
  }

  describe 'load user info config' do
    subject { @config.load }
    it { is_expected.to have_key('email') }
    it { is_expected.to have_key('password') }
    it { is_expected.to have_key('company') }
    it { is_expected.to have_key('uid') }
    it { is_expected.to have_key('room_id') }
  end

end