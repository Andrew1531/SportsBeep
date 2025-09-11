class ReprocessAvatarWorker < ::CarrierWave::Workers::Base
  include Sidekiq::Worker

  sidekiq_options retry: 3

  def perform(*args)
    record = super(*args)
    if record
      logger.info "Reprocessing avatar for User #{record.id}"
      record.process_avatar_upload = true
      record.avatar.cache_stored_file!
      record.avatar.retrieve_from_cache!(record.avatar.cache_name)
      record.avatar.recreate_versions!
      record.save!
      record.update_attribute :avatar_processing, false
    else
      logger.info "Couldn't find record. Args given were: #{args}"
    end
  end

end