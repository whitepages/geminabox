require "fileutils"

class Geminabox::DiskCache
  attr_reader :root_path

  def initialize(root_path)
    @root_path = root_path
    ensure_dir_exists!
  end

  def flush_key(key)
    path = path(key_hash(key))
    FileUtils.rm_f(path)
  end

  def flush
    FileUtils.rm_rf(root_path)
    ensure_dir_exists!
  end

  def cache(key)
    key_hash = key_hash(key)
    read(key_hash) || write(key_hash, yield)
  end

  def marshal_cache(key, logger)
    key_hash = key_hash(key)
    cached_value = marshal_read(key_hash)
    if cached_value
      cached_value
    else
      logger.info "No cached value found for '#{key}' (cache '#{key_hash}') - generating"
      cached_value = marshal_write(key_hash, yield)
      logger.info "New value cached for '#{key}' (cache '#{key_hash}')"
      cached_value
    end
  end

protected

  def ensure_dir_exists!
    FileUtils.mkdir_p(root_path)
  end

  def key_hash(key)
    Digest::MD5.hexdigest(key)
  end

  def path(key_hash)
    File.join(root_path, key_hash)
  end

  def read(key_hash)
    read_int(key_hash) { |path| File.read(path) }
  end

  def marshal_read(key_hash)
    read_int(key_hash) { |path| Marshal.load(File.open(path)) }
  end

  def read_int(key_hash)
    path = path(key_hash)
    yield(path) if File.exists?(path)
  end

  def write(key_hash, value)
    write_int(key_hash) { |f| f << value }
    value
  end

  def marshal_write(key_hash, value)
    write_int(key_hash) { |f| Marshal.dump(value, f) }
    value
  end

  def write_int(key_hash)
    File.open(path(key_hash), 'wb') { |f| yield(f) }
  end

end
