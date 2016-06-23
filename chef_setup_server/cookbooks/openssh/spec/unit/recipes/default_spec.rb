require 'spec_helper'

describe 'openssh::default' do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  it 'installs the openssh packages' do
    expect(chef_run).to install_package('openssh-client')
    expect(chef_run).to install_package('openssh-server')
  end

  it 'starts the ssh service' do
    expect(chef_run).to start_service('ssh')
    expect(chef_run).to enable_service('ssh')
  end

  it 'writes the ssh_config' do
    template = chef_run.template('/etc/ssh/ssh_config')
    expect(template).to be
    expect(template.mode).to eq('0644')
    expect(template.owner).to eq('root')
    # expect(template.group).to eq('root') # disabled until fauxhai supports root_group
  end

  describe 'sshd_config' do
    it 'writes the sshd_config' do
      template = chef_run.template('/etc/ssh/sshd_config')
      expect(template).to be
      expect(template.mode).to eq('0644')
      expect(template.owner).to eq('root')
      # expect(template.group).to eq('root') # disabled until fauxhai supports root_group
    end

    it 'allow legacy default AuthorizedKeysFile behavior' do
      expect(chef_run).to_not render_file('/etc/ssh/sshd_config').with_content(/AuthorizedKeysFile.*/)
    end

    it 'writes a match group block' do
      chef_run.node.set['openssh']['server']['match'] = { 'Group admins' => { 'permit_tunnel' => 'yes' } }
      chef_run.converge(described_recipe)
      expect(chef_run).to render_file('/etc/ssh/sshd_config').with_content(/Match Group admins\n\s\sPermitTunnel yes/)
    end

    it 'skips match group block' do
      chef_run.node.set['openssh']['server']['match'] = {}
      chef_run.converge(described_recipe)
      expect(chef_run).to_not render_file('/etc/ssh/sshd_config').with_content(/Match Group admins\n\s\sPermitTunnel yes/)
    end
  end

  context 'port set without listen address set' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set['openssh']['server']['port'] = 1234
      end.converge(described_recipe)
    end

    it 'writes out port at the top of the config' do
      expect(chef_run).to render_file('/etc/ssh/sshd_config')
        .with_content(/# Do NOT modify this file by hand!\n\nPort 1234/)
    end
  end
end
