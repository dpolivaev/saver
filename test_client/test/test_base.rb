require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/externals_new'
require_relative '../src/externals_future'

class TestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

     OLD_TEST_MARK = '<old>'
     NEW_TEST_MARK = '<new>'
  FUTURE_TEST_MARK = '<future>'

  def future_test?
    test_name.start_with?(FUTURE_TEST_MARK)
  end

  def new_test?
    test_name.start_with?(NEW_TEST_MARK)
  end

  def self.old_new_future_test(hex_suffix, *lines, &block)
    self.old_new_test(hex_suffix, *lines, &block)
    self.future_test(hex_suffix, *lines, &block)
  end

  def self.old_new_test(hex_suffix, *lines, &block)
    self.old_test(hex_suffix, *lines, &block)
    self.new_test(hex_suffix, *lines, &block)
  end

  def self.old_test(hex_suffix, *lines, &block)
    old_lines = [OLD_TEST_MARK] + lines
    test(hex_suffix+'0', *old_lines, &block)
  end

  def self.new_test(hex_suffix, *lines, &block)
    new_lines = [NEW_TEST_MARK] + lines
    test(hex_suffix+'1', *new_lines, &block)
  end

  def self.future_test(hex_suffix, *lines, &block)
    future_lines = [FUTURE_TEST_MARK] + lines
    test(hex_suffix+'2', *future_lines, &block)
  end

  # - - - - - - - - - - - - - - - - - -

  def externals
    if future_test?
      @externals ||= ExternalsFuture.new
    elsif new_test?
      @externals ||= ExternalsNew.new
    else
      @externals ||= Externals.new
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def assert_service_error(message, &block)
    if new_test? || future_test?
      error = assert_raises(ArgumentError) { block.call }
      assert_equal message, error.message
    else
      error = assert_raises(ServiceError) { block.call }
      json = JSON.parse(error.message)
      assert_equal message, json['message']
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def saver
    externals.saver
  end

  def group
    externals.group
  end

  def kata
    externals.kata
  end

  def id_generator
    externals.id_generator
  end

  def starter
    externals.starter
  end

  # - - - - - - - - - - - - - - - - - -

  def make_ran_test_args(id, n, files)
    [ id, n, files, time_now, duration, stdout, stderr, status, red ]
  end

  def time_now
    [2016,12,2, 6,14,57,4587]
  end

  def duration
    1.778
  end

  def stdout
    file('')
  end

  def stderr
    file('Assertion failed: answer() == 42')
  end

  def status
    23
  end

  def red
    'red'
  end

  def edited_files
    { 'cyber-dojo.sh' => file('gcc'),
      'hiker.c'       => file('#include "hiker.h"'),
      'hiker.h'       => file('#ifndef HIKER_INCLUDED'),
      'hiker.tests.c' => file('#include <assert.h>')
    }
  end

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

  def event0
    zero = {
      'event'  => 'created',
      'time'   => creation_time
    }
    if future_test?
      zero['index'] = 0
    end
    zero
  end

  def creation_time
    starter.creation_time
  end

end
