class Factorio
  class SaveService < BaseService
    def current
      if factorio_saves_dir.exist?
        name = factorio_saves_dir.readlink.basename.to_s
        return Save.new(self, name)
      end
    end

    def set_current(save)
      prev_save = current
      factorio.server.while_stopped do
        if prev_save
          factorio_saves_dir.unlink
        end

        factorio_saves_dir.make_symlink(save.location)
      end
      prev_save
    end

    def all
      location.children.select do |entry|
        entry.directory? && entry.basename.to_s != '.' && entry.basename.to_s != '..'
      end.map do |entry|
        Save.new(self, entry.basename.to_s)
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
      @service = service
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

    def head
      location.join(service.factorio.config['save_name'] + '.zip')
    end

    # will be populated by the factorio service when it sees no save in the
    # folder.
    def create
      location.mkdir
    end

    def write(data)
      if current?
        service.factorio.server.while_stopped do
          return _write(data)
        end
      end
      return _write(data)
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

    private

    def _write(data)
      # TODO: validate data
      head.open('wb') do |file|
        file.write(data)
      end
    end
  end # end class
end
