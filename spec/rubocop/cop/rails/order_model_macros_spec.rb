require 'spec_helper'
require 'pry'

describe RuboCop::Cop::Rails::OrderModelMacros do
  subject(:cop) { described_class.new }

  before do
    load_config_for cop, :default
  end

  context 'without inheritance' do
    let(:without_inheritance_sourde) do
      inspect_source(
        cop,
        [
          'module Bar',
          '  class Foo',
          '     has_one :foo',
          '     has_and_belongs_to_many :bar',
          '',
          '     after_create :hoge',
          '     before_create :fuga',
          '  end',
          'end'
        ]
      )
    end

    it 'recognizes the correct outer groupings' do
      without_inheritance_sourde

      expect(cop.messages).to eq []
    end
  end

  context 'outer grouping' do
    let(:valid_source) do
      inspect_source(
        cop,
        [
          'module Bar',
          '  class Foo < ActiveRecord::Base',
          '     has_one :foo',
          '     has_and_belongs_to_many :bar',
          '',
          '     after_create :hoge',
          '     before_create :fuga',
          '  end',
          'end'
        ]
      )
    end

    it 'recognizes the correct outer groupings' do
      valid_source

      expect(cop.messages).to eq []
    end

    let(:outer_grouping_error_source) do
      inspect_source(
        cop,
        [
          'module Bar',
          '  class Foo < ActiveRecord::Base',
          '     default_scope :blah',
          '',
          '     enum :boo',
          '',
          '     after_create :hoge',
          '     before_create :fuga',
          '',
          '     has_one :foo',
          '     has_and_belongs_to_many :bar',
          '',
          '     scope :foo',
          '     validates :foo',
          '  end',
          'end'
        ]
      )
    end

    it 'recognizes the correct first grouping error' do
      outer_grouping_error_source

      expect(cop.messages.first).to match(/Move associations above callbacks/)
      expect(cop.offenses.map(&:line).sort).to eq([3])
    end

    context 'custom macros' do
      before { load_config_for cop, :custom }

      let(:custom_macro_source) do
        inspect_source(
          cop,
          [
            'module Bar',
            '  class Foo < ActiveRecord::Base',
            '     record_locked_by :foo',
            '',
            '     belongs_to :cat',
            '',
            '     scope :bar',
            '  end',
            'end'
          ]
        )
      end

      it 'recognizes errors with custom macros' do
        custom_macro_source

        expect(cop.messages.first).to match(/Move associations above customs/)
        expect(cop.offenses.map(&:line).sort).to eq([3])
      end
    end
  end

  context 'inner grouping' do
    let(:inner_grouping_error_source) do
      inspect_source(
        cop,
        [
          'module Bar',
          '  class Foo < ActiveRecord::Base',
          '     has_and_belongs_to_many :bar',
          '     has_one :foo',
          '     belongs_to :cat',
          '  end',
          'end'
        ]
      )
    end

    it 'recognizes the correct ordering error within groups' do
      inner_grouping_error_source

      expect(cop.messages.first).to match(/Not sorted within association/)
      expect(cop.messages.first).to match(/Move belongs_to above has_and_belongs_to_many/)
      expect(cop.offenses.map(&:line).sort).to eq([3])
    end
  end

  def load_config_for(cop, config_type)
    return load_default_config_for(cop) if config_type == :default

    config_file = File.expand_path(__FILE__ + "/../../../../support/#{config_type}.yml")

    config_hash = RuboCop::ConfigLoader.send(:load_yaml_configuration, config_file)
    config = RuboCop::ConfigLoader.merge_with_default(RuboCop::Config.new(config_hash, config_file), config_file)

    cop.instance_variable_set(:@config, config)
  end

  def load_default_config_for(cop)
    cop.instance_variable_set(:@config, RuboCop::ConfigLoader.default_configuration)
  end
end
