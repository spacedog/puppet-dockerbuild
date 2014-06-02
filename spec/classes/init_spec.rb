require 'spec_helper'
describe 'dockerbuild' do

  context 'with defaults for all parameters' do
    it { should contain_class('dockerbuild') }
  end
end
