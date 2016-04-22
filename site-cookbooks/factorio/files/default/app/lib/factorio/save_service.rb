class Factorio
  class SaveService < BaseService
    def current
      name = factorio.storage_location.join('saves').readlink.basename
      Save.new(self, name)
    end

    def set_current(save)
      prev_save = current_save
      factorio.while_stopped do
        factorio_saves_dir.unlink.symlink(save.location)
      end
      prev_save
    end

    def all
      location.entries.select do |entry|
        entry.directory? && entry.basename != '.' && entry.basename != '..'
      end.map do |entry|
        Save.new(self, entry.basename)
      end
    end

    def create(name)
      Save.new(self, name)
    end

    def location
      factorio.storage_location.join('save_dirs')
    end

    def factorio_saves_dir
      factorio.storage_location.join('saves')
    end

    def to_json(state = nil)
      {
        :all => all,
        :current => current,
      }.to_json(state)
    end
  end # end class

  # a Save in our service is a folder containing a primary factorio map, and
  # possibly several factorio autosaves. It can contain no files, in which case
  # the factorio service will create a new map when starting up.
  class Save
    attr_reader :service, :name

    def initialize(service, name)
      if name !~ /[\w_\s]+/
        raise "save cannot have name with unusual characters, was '#{name}'"
      end

      @name = name
      @service = factorio
    end

    def exist?
      location.exist?
    end

    def current?
      service.current == self
    end

    def location
      Pathname.new(service.location.join(name))
    end

    # will be populated by the factorio service when it sees no save in the
    # folder.
    def create
      location.mkdir
    end

    def write(data)
      # TODO: validate data
      save_path = location.join(service.factorio.config['save_name'] + '.zip')
      save_path.open('w') do |file|
        file.write(data)
      end
    end

    def ==(other)
      if other.class == self.class
        other.service == self.service && other.name == self.name
      else
        false
      end
    end

    def to_json(state = nil)
      { :name => name }.to_json(state)
    end
  end # end class
end
