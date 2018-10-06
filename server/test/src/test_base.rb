require_relative 'hex_mini_test'
require_relative 'external_starter'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def sha
    grouper.sha
  end

  # - - - - - - - - - - - - - - - - -

  def create(manifest, files)
    grouper.create(manifest, files)
  end

  def manifest(id)
    grouper.manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def id?(id)
    grouper.id?(id)
  end

  # - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    grouper.join(id, indexes)
  end

  def joined(id)
    grouper.joined(id)
  end

  # - - - - - - - - - - - - - - - - -

  def stub_create(stub_id)
    manifest = starter.manifest
    manifest['id'] = stub_id
    id = create(manifest, starter.files)
    assert_equal stub_id, id
    id
  end

  # - - - - - - - - - - - - - - - - -

  def starter
    ExternalStarter.new
  end

  def externals
    @externals ||= Externals.new
  end

  private

  def grouper
    externals.grouper
  end

end