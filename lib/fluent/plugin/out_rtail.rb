class Fluent::RtailOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('rtail', self)

  unless method_defined?(:log)
    define_method('log') { $log }
  end

  include Fluent::SetTimeKeyMixin
  include Fluent::SetTagKeyMixin

  config_param :host,                  :string,  default: '127.0.0.1'
  config_param :port,                  :integer, default: 9999
  config_param :id_key,                :string,  default: 'id'
  config_param :content_key,           :string,  default: 'content'
  config_param :use_tag_as_id,         :bool,    default: false
  config_param :use_record_as_content, :bool,    default: false

  def initialize
    super
    require 'multi_json'
    require 'socket'
  end

  def configure(conf)
    super
    @socket = UDPSocket.new
    @socket.connect(@host, @port)
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

   def write(chunk)
    chunk = chunk.to_enum(:msgpack_each)

    chunk.each do |tag, time, record|
      log_stream_id = get_log_stream_id(tag, time, record)
      next unless log_stream_id

      content = get_content(tag, time, record)
      next unless content

      send_message(log_stream_id, time, content)
    end
  rescue => e
    log.error e.message
    log.error_backtrace e.backtrace
  end

  private

  def get_log_stream_id(tag, time, record)
    if @use_tag_as_id
      tag
    else
      log_stream_id = record[@id_key]

      unless log_stream_id
        log.warn("'#{@id_key}' key does not exist: #{[tag, time, record].inspect}")
      end

      log_stream_id
    end
  end

  def get_content(tag, time, record)
    if @use_record_as_content
      record
    else
      content = record[@content_key]

      if content
        content = content.to_s
      else
        log.warn("'#{@content_key}' key does not exist: #{[tag, time, record].inspect}")
      end

      content
    end
  end

  def send_message(log_stream_id, time, content)
    message = {
      'id' => log_stream_id,
      'timestamp' => (time.to_f * 1000).to_i,
      'content' => content,
    }

    message = MultiJson.dump(message)
    @socket.send(message, 0)
  end
end
