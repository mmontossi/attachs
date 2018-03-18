module Attachs
  class Storage

    def url(path)
      base_url = configuration.base_url
      if base_url.present?
        Pathname.new(base_url).join(path).to_s
      else
        Pathname.new('/').join(prefix).join(path).to_s
      end
    end

    def process(id, upload_path, style_paths, content_type, options)
      ensure_folder id
      processor = build_processor(upload_path, content_type)
      if processor
        style_paths.except(:original).each do |style, path|
          processor.process expand_path(path), options[style]
        end
      end
      move upload_path, expand_path(style_paths[:original])
    end

    def destroy(path)
      delete expand_path(path)
    end

    def clear
      find_each do |path|
        delete path
      end
    end

    private

    delegate :configuration, to: :Attachs

    def base_path
      Rails.root.join('public').join(prefix)
    end

    def prefix
      configuration.prefix || ''
    end

    def expand_path(path)
      base_path.join(path).to_s
    end

    def ensure_folder(id)
      FileUtils.mkdir_p base_path.join(id)
    end

    def move(current_path, new_path)
      Rails.logger.info "Moving: #{current_path} => #{new_path}"
      FileUtils.mv current_path, new_path
    end

    def remove(path)
      Rails.logger.info "Deleting: #{path}"
      FileUtils.rm path
    end

    def find_each
      Dir[base_path.join('*/*/**')].each do |path|
        yield path
      end
    end

    def build_processor(path, content_type)
      case content_type
      when /^image\//
        Processors::Image.new path
      end
    end

  end
end
