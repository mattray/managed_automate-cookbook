# # encoding: utf-8

# Inspec test for recipe managed-automate2::default

# This is an example test, replace it with your own test.
describe port(80) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end
