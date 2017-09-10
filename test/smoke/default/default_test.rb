# # encoding: utf-8

# Inspec test for recipe zookeeper::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
# To make sure the service is up
sleep(30)

describe service 'zookeeper' do
  it { should be_enabled }
  it { should be_running }
end

describe port 2181 do
  it { should be_listening }
end
