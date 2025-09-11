class Background
  class << self

    def push(worker, *arguments)
      Sidekiq::Client.enqueue(worker, *arguments)
    end

    def schedule(worker, timestamp, *arguments)
      worker.perform_at(timestamp, *arguments)
    end

  end
end