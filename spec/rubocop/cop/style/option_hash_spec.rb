# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::OptionHash, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'SuspiciousParamNames' => ['options'] } }

  let(:source) do
    [
      'def some_method(options = {})',
      '  puts some_arg',
      'end'
    ]
  end

  it 'registers an offense' do
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages.first)
      .to eq('Prefer keyword arguments to options hashes.')
    expect(cop.highlights).to eq ['options = {}']
  end

  context 'when the last argument is an options hash named something else' do
    let(:source) do
      [
        'def steep(flavor, duration, config={})',
        '  mug = config.fetch(:mug)',
        '  prep(flavor, duration, mug)',
        'end'
      ]
    end

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense when in SuspiciousParamNames list' do
      cop_config['SuspiciousParamNames'] = ['config']

      inspect_source(cop, source)

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first)
        .to eq('Prefer keyword arguments to options hashes.')
      expect(cop.highlights).to eq ['config={}']
    end
  end

  context 'when there are no arguments' do
    before(:each) do
      inspect_source(cop, source)
    end

    let(:source) do
      [
        'def meditate',
        '  puts true',
        '  puts true',
        'end'
      ]
    end

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when the last argument is a non-options-hash optional hash' do
    before(:each) do
      inspect_source(cop, source)
    end

    let(:source) do
      [
        'def cook(instructions, ingredients = { hot: [], cold: [] })',
        '  prep(ingredients)',
        'end'
      ]
    end

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end
end
