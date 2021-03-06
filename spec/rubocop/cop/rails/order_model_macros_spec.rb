require 'spec_helper'
require 'pry'

describe RuboCop::Cop::Rails::OrderModelMacros do
  subject(:cop) { described_class.new }

  before do
    load_config_for cop, :default
  end

  context 'without inheritance' do
    let(:without_inheritance_source) do
      inspect_source(
        [
          'module Bar',
          '  class Foo',
          '     has_one :foo',
          '     has_and_belongs_to_many :bar',
          '',
          '     after_create :meow',
          '     before_create :moo',
          '  end',
          'end'
        ]
      )
    end

    it 'recognizes the correct outer groupings' do
      without_inheritance_source

      expect(cop.messages).to eq []
    end
  end

  context 'with other things' do
    let(:with_other_things_source) do
      inspect_source(
        [
          'module Bar',
          '  class Foo < ActiveRecord::Base',
          '     extend Razzle::Daz',
          '     include ::Bazzle::Baz',
          '',
          '     MY_CONST = "cats"',
          '',
          '     has_one :foo',
          '',
          '     has_and_belongs_to_many :bar',
          '',
          '     after_create :meow',
          '     before_create :boo',
          '',
          '     scope :blue, ->(green) { green.teal }',
          '',
          '     def self.rar',
          '       splat',
          '     end',
          '',
          '     def kitten',
          '       puts "meow"',
          '     end',
          '  end',
          'end'
        ]
      )
    end

    it 'recognizes the correct outer groupings' do
      with_other_things_source

      expect(cop.messages).to eq []
    end
  end

  context 'outer grouping' do
    context 'properly ordered' do
      let(:valid_source1) do
        inspect_source(
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
        valid_source1

        expect(cop.messages).to eq []
      end
    end

    context 'invalid order' do
      context 'basic ordering error' do
        let(:outer_grouping_error_source) do
          inspect_source(
            [
              'module Bar',
              '  class Foo < ActiveRecord::Base',
              '     default_scope :blah',
              '',
              '     enum :boo',
              '',
              '     after_create :who',
              '     before_create :wha',
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
      end

      context 'with callback passed a block' do
        let(:block_callback_source) do
          inspect_source(
            [
              'module Bar',
              '  class Foo < ActiveRecord::Base',
              '     has_one :foo',
              '     has_and_belongs_to_many :bar',
              '',
              '     after_create do',
              '       do_something',
              '     end',
              '',
              '     validate :baz',
              '  end',
              'end'
            ]
          )
        end

        it 'recognizes the the callback group' do
          block_callback_source

          expect(cop.messages.first).to match(/Move validations above callbacks/)
          expect(cop.offenses.map(&:line).sort).to eq([3])
        end
      end

      context 'with with_options validations' do
        let(:with_options_validation_source) do
          inspect_source(
            [
              'module Bar',
              '  class Foo < ActiveRecord::Base',
              '    with_options(:on_something) do |u|',
              '      u.validates :foo, presence: true',
              '    end',
              '',
              '    default_scope { where(:bar) }',
              '  end',
              'end'
            ]
          )
        end

        it 'recognizes the the validations block' do
          with_options_validation_source

          expect(cop.messages.first).to match(/Move default_scopes above validations/)
          expect(cop.offenses.map(&:line).sort).to eq([3])
        end
      end
    end

    context 'custom macros' do
      before { load_config_for cop, :custom }

      let(:custom_macro_source) do
        inspect_source(
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
    context 'basic invalid ordering' do
      let(:inner_grouping_error_source) do
        inspect_source(
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

    context 'mixed invalid ordering' do
      let(:mixed_invalid_inner_source) do
        inspect_source(
          [
            'module Bar',
            '  class Foo < ActiveRecord::Base',
            '     cattr_reader :moo',
            '',
            '     has_many :fa',
            '     has_many :la',
            '     has_and_belongs_to_many :ti',
            '     has_many :so',
            '',
            '     validates :bar',
            '     validate :foo',
            '     validates :cat',
            '  end',
            'end'
          ]
        )
      end

      it 'recognizes the correct ordering error within groups' do
        mixed_invalid_inner_source

        expect(cop.messages.first).to match(/Not sorted within associations/)
        expect(cop.messages.first).to match(/Group association types together/)
        expect(cop.offenses.map(&:line).sort).to eq([3])
      end
    end

    context 'mixed invalid with Gems' do
      before {  load_config_for cop, :gem }

      let(:mixed_invaild_gems) do
        inspect_source(
          [
            'module Bar',
            '  class Foo < ActiveRecord::Base',
            '     has_many :la',
            '     has_and_belongs_to_many :ti',
            '     has_many :so',
            '',
            '     delegate :bar',
            '     acts_as_list :foo',
            '     delegate :cat',
            '  end',
            'end'
          ]
        )
      end

      it 'recognizes the correct ordering error' do
        mixed_invaild_gems

        expect(cop.messages.first).to match(/Macro method groups not sorted/)
        expect(cop.messages.first).to match(/Group delegate together/)
        expect(cop.offenses.map(&:line).sort).to eq([3])
      end
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
