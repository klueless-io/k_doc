# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::Action do
  subject { instance }

  let(:instance) { described_class.new('some_name', &block) }
  let(:block) { nil }
  let(:sample_data) { CSV.parse(File.read(file), headers: true, header_converters: :symbol).map(&:to_h) }

  describe '.key' do
    subject { instance.key }

    it { is_expected.to eq('some_name') }
  end

  describe '.type' do
    subject { instance.type }

    it { is_expected.to eq(KDoc.opinion.default_action_type) }
  end

  describe '.data' do
    subject { instance.data }

    it { is_expected.to eq('') }
  end
end
