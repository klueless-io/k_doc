# frozen_string_literal: true

RSpec.describe KDoc do
  it 'has a version number' do
    expect(KDoc::VERSION).not_to be nil
  end

  it 'has a standard error' do
    expect { raise KDoc::Error, 'some message' }
      .to raise_error('some message')
  end
end
