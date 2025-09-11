# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include ::CarrierWave::Backgrounder::Delay

  version :mdpi do
    process resize_to_fill: [72, 72]
  end

  version :hdpi do
    process resize_to_fill: [108, 108]
  end

  version :xhdpi do
    process resize_to_fill: [144, 144]
  end

  version :xxhdpi do
    process resize_to_fill: [216, 216]
  end

  version :xxxhdpi do
    process resize_to_fill: [288, 288]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    "avatar-#{model.avatar_uuid}.png"
  end

end
