# TODO: rename file to something else

module Chopped
  # CombinedScope is an alternative to calling dsl_obj.instance_eval directly on
  # a DSL implementation object. If you wrap your dsl object in a CombinedScope,
  # you can evaluate blocks in a way that retains their initial scope.
  #
  # Example:
  # # in your library
  # def dsl(&block)
  #   dsl_obj = MyModule::DSL.new
  #   scope = CombinedScope.new(dsl_obj)
  #   scope.evaluate(block)
  # end
  #
  # # in a user's class
  # class Foo
  #   def expensive_calculation
  #     @result ||= perform_calculation
  #   end
  #   def use_dsl
  #     dsl do
  #       # you can access these methods on the parent scope's `self`
  #       # this is usually not possible with instance_eval based DSLs
  #       use expensive_cacluation
  #       use_again expensive_calculcation
  #     end
  #   end
  # end
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
          self.send(base_impl, block)
        end

        # otherwise call base implementation
        self.send(base_impl)
      end
    end
  end
end
