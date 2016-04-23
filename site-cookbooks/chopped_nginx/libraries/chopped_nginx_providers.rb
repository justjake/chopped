module Chopped

  class CombinedScope
    def initialize(child)
      @child = child
    end

    def evaluate(block)
      @parent = block.binding.eval('self')
      instance_eval(&block)
    end

    def method_missing(method, *args, &blk)
      if @child.respond_to? method
        @child.send(method, *args, &blk)
      else
        @parent.send(method, *args, &blk)
      end
    end
  end

  # extend Chopped::BlockPropertySupport to get a class method `block_property`
  # that allows your resoure to take a ruby block
  #
  # in your resource:
  # extend Chopped::BlockPropertySupport
  # block_property :bark
  #
  # in your recipe:
  # my_resource "/etc/foo" do
  #   bark do
  #     custom_dsl_here
  #     implemented_by_you
  #   end
  # end
  module BlockPropertySupport
    # define a new property that takes a block as its type
    def block_property(name, **options)
      # this defines a property the normal way with the right options
      property(name, Proc, **options)
      # the property defined a method `name` that is a getter+setter method.
      # unfortunatley chef will throw if that method is given a block,
      # so we must redefine it.

      # move existing method out of the way
      base_impl = (name.to_s + '_base_implementation').to_sym
      alias_method(base_impl, name)

      # define the new version
      define_method(name) do |value = Chef::NOT_PASSED, &block|
        # set when a block is given
        if !block.nil?
          Chef::Log.info("property #{name} recieved block #{block}")
          self.send(base_impl, block)
        end

        # otherwise call base implementation
        self.send(base_impl)
      end
    end
  end
end
