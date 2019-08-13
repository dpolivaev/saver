require_relative 'test_base'
require_relative '../src/external_disk'

class ExternalDiskTest < TestBase

  def self.hex_prefix
    'FDF'
  end

  def disk
    ExternalDisk.new
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '435',
  'exist? can already be true' do
    assert disk.exist?('/tmp')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '436',
  'make succeeds once then fails' do
    name = '/cyber-dojo/groups/FD/F4/36'
    assert disk.make?(name)
    refute disk.make?(name)
    refute disk.make?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'exists? is true after a successful make' do
    name = '/cyber-dojo/groups/FD/F4/37'
    refute disk.exist?(name)
    assert disk.make?(name)
    assert disk.exist?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438',
  'read() reads back what write() writes' do
    filename = '/cyber-dojo/groups/FD/F4/38/limerick.txt'
    content = 'the boy stood on the burning deck'
    disk.write(filename, content)
    assert_equal content, disk.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '439',
  'read() a non-existant file is nil' do
    filename = '/cyber-dojo/groups/12/23/34/not-there.txt'
    assert_nil disk.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '440',
  'read() accepts an array of filenames (BatchMethod)' do
    dir = '/cyber-dojo/groups/34/56/78/'
    there_not = dir + 'there-not.txt'
    there_yes = dir + 'there-yes.txt'
    disk.write(there_yes, 'content is this')
    reads = disk.read([there_not, there_yes])
    assert_equal [nil,'content is this'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '441',
  'read() can read across different sub-dirs' do
    filename1 = '/cyber-dojo/groups/C1/bc/1A/1/kata.id'
    disk.write(filename1, 'be30e5')
    filename2 = '/cyber-dojo/groups/C1/bc/1A/14/kata.id'
    disk.write(filename2, 'De02CD')
    reads = disk.read([filename1, filename2])
    assert_equal ['be30e5','De02CD'], reads
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '539',
  'append() appends to the end' do
    filename = '/cyber-dojo/groups/FD/F4/39/readme.md'
    content = 'hello world'
    disk.append(filename, content)
    assert_equal content, disk.read(filename)
    disk.append(filename, content.reverse)
    assert_equal "#{content}#{content.reverse}", disk.read(filename)
  end

end
