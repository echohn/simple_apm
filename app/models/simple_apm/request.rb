# 单个请求信息
module SimpleApm
  class Request
    attr_accessor :request_id, :action_name,
                  :during, :started, :db_runtime, :view_runtime,
                  :controller, :action, :format, :method,
                  :host, :remote_addr, :url, :completed_memory, :memory_during,
                  :exception, :status, :net_http_during
    def initialize(h)
      h.each do |k, v|
        send("#{k}=", v) rescue puts "attr #{k} not set!"
      end
    end

    def net_http_requests
      @requests ||= SimpleApm::HttpRequest.find_by_request_id(request_id)
    end

    def sqls
      @sqls ||= SimpleApm::Sql.find_by_request_id(request_id)
    end


    class << self

      def find(id)
        SimpleApm::Request.new JSON.parse(SimpleApm::Redis.hget(key, id)) rescue nil
      end

      def create(h)
        SimpleApm::Redis.hmset key, h['request_id'], h.to_json
      end

      def key
        SimpleApm::RedisKey['requests']
      end
    end
  end
end
