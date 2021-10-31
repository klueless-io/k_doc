# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::CsvDoc do
  subject { instance }

  let(:instance) { described_class.new('some_name', &block) }
  let(:block) { nil }

  context '.key' do
    subject { instance.key }

    it { is_expected.to eq('some_name') }
  end

  context '.type' do
    subject { instance.type }

    it { is_expected.to eq(KDoc.opinion.default_csv_type) }
  end
end
