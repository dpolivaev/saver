# frozen_string_literal: true

require_relative 'liner'
require 'json'

class Grouper

  def initialize(externals)
    @externals = externals
  end

  def ready?
    true
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_exists?(id)
    saver.exist?(id_path(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_create(manifest)
    id = manifest['id'] = group_id_generator.id
    manifest['visible_files'] = lined_files(manifest['visible_files'])
    group_exists,_write_result = saver.batch([
      make_cmd(id),
      manifest_write_cmd(id, manifest)
    ])
    unless group_exists
      fail invalid('id', id)
    end
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_manifest(id)
    group_exists,manifest_src = saver.batch([
      exist_cmd(id),
      manifest_read_cmd(id)
    ])
    unless group_exists
      fail invalid('id', id)
    end
    manifest = json_parse(manifest_src)
    manifest['visible_files'] = unlined_files(manifest['visible_files'])
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, indexes)
    assert_group_exists(id)
    index = indexes.detect { |new_index|
      make?(id, new_index) # TODO: batch this too!!!
    }
    if index.nil?
      nil
    else
      manifest = group_manifest(id)
      manifest.delete('id')
      manifest['group_id'] = id
      manifest['group_index'] = index
      kata_id = singler.kata_create(manifest)
      write(id, index, 'kata.id', kata_id)
      kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_joined(id)
    if !group_exists?(id)
      nil
    else
      kata_indexes(id).map{ |kata_id,_| kata_id }
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_events(id)
    if !group_exists?(id)
      events = nil
    else
      indexes = kata_indexes(id) # BatchMethod-1
      filenames = indexes.map do |kata_id,_index|
        args = ['', 'cyber-dojo', 'katas']
        args += [kata_id[0..1], kata_id[2..3], kata_id[4..5]]
        args += ['events.json']
        File.join(*args)
      end
      katas_events = saver.batch_read(filenames)
      events = {}
      indexes.each.with_index(0) do |(kata_id,index),offset|
        events[kata_id] = {
          'index' => index,
          'events' => group_events_parse(katas_events[offset])
        }
      end
    end
    events
  end

  private

  def make_cmd(id, *parts)
    ['make?', id_path(id, *parts)]
  end

  def exist_cmd(id, *parts)
    ['exist?', id_path(id, *parts)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  def manifest_write_cmd(id, manifest)
    ['write', id_path(id, manifest_filename), json_pretty(manifest)]
  end

  def manifest_read_cmd(id)
    ['read', id_path(id, manifest_filename)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def make?(id, *parts)
    saver.make?(id_path(id, *parts))
  end

  def write(id, *parts, content)
    saver.write(id_path(id, *parts), content)
  end

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'cyber-dojo', 'groups', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  include Liner

  def kata_indexes(id)
    filenames = (0..63).map do |index|
      id_path(id, index, 'kata.id')
    end
    reads = saver.batch_read(filenames)
    reads.each.with_index(0).select{ |kata_id,_| kata_id }
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def assert_group_exists(id)
    unless group_exists?(id)
      fail invalid('id', id)
    end
  end

  def group_events_parse(s)
    JSON.parse!('[' + s.lines.join(',') + ']')
    # Alternative implemenation, which tests show is slower.
    # s.lines.map { |line| JSON.parse!(line) }
  end

  # - - - - - - - - - - - - - -

  def json_pretty(o)
    JSON.pretty_generate(o)
  end

  def json_parse(s)
    JSON.parse!(s)
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    ArgumentError.new("#{name}:invalid:#{value}")
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

  def group_id_generator
    @externals.group_id_generator
  end

  def singler
    @externals.singler
  end

end
