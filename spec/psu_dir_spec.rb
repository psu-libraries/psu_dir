# frozen_string_literal: true

RSpec.describe PsuDir do
  it 'has a version number' do
    expect(PsuDir::VERSION).not_to be nil
  end

  it 'sets ldap_unwilling_sleep' do
    expect(described_class.ldap_unwilling_sleep).to eq(0)
  end

  it 'sets a logger' do
    expect(described_class.logger).to be_a(Logger)
  end
end
