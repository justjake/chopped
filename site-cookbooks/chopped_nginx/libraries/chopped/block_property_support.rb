module Chopped
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
          self.send(base_impl, block)
        end

        # otherwise call base implementation
        self.send(base_impl)
      end
    end
  end # end BlockPropertySupport
end
