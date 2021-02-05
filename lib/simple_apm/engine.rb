module SimpleApm
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      if SimpleApm::Setting::EXCLUDE_URLS_IN_RAKE.include? env['ORIGINAL_FULLPATH']
        return @app.call(env)
      end

      if SimpleApm::Redis.ping && SimpleApm::Redis.running?
        SimpleApm::ProcessingThread.start!
        Thread.current['action_dispatch.request_id'] = env['action_dispatch.request_id']
        Thread.current[:current_process_memory] = GetProcessMem.new.mb
        Thread.current[:net_http_during] = 0.0
      end
      @app.call(env)
    end
  end

  class Engine < ::Rails::Engine
    isolate_namespace SimpleApm
    config.app_middleware.use SimpleApm::Rack
    config.assets.precompile += %w(
      simple_apm/bootstrap.min.js
      simple_apm/echarts.js
      simple_apm/jquery.dataTables.min.js
      simple_apm/jquery.min.js
      simple_apm/bootstrap.min.css
      simple_apm/jquery.dataTables.min.css
    )
  end

end
