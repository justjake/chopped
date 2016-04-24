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
end
