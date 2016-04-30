module Chopped
  module Nginx
    module DSL
      # Load a list of nginx directives that this module should support.
      # Directive files are newline-seperated text files where each directive
      # is the first word of a line. You can generate this list by pasting the
      # page text of directives from http://nginx.org/en/docs/dirindex.html
      # This library includes that list - and provides this method to allow
      # support for NGINX extensions.
      def self.load_support(text_file_path)
        lines = Pathname.new(text_file_path).read.split("\n")
        lines.each do |line|
          directive = line.split(/\s+/).first
          support_directive(directive)
        end
      end

      # add support for a single directive.
      # @param [String, Symbol] meth the directive name
      # @see http://nginx.org/en/docs/dirindex.html
      #
      # this functionality was originally implemented in method_missing, and
      # allowed any word as a directive, but that prevented intelligent_eval
      # from accessing the parent scope of a block.
      def self.support_directive(meth)
        meth = meth.to_sym
        define_method(meth) do |*args, &block|
          if !block.nil?
            total = [meth].concat(args)
            self._context(*total, &block)
          else
            self._directive(meth, *args)
          end
        end
      end

      # Load support for all standard nginx directives.
      # We do this here so we would override nginx directives that conflict with
      # our own methods.
      load_support(
        Pathname.new(__FILE__).dirname.join('directives_list.txt').to_s
      )

      # a more intelligent instance_eval that allows both styles of dsl:
      #
      # foo do |f|
      #   f.a :hello
      #   f.b :world
      # end
      #
      # and
      #
      # foo do
      #   a :hello
      #   b :world
      # end
      #
      # also preserve the scope of block.
      # @param [Proc] block a dsl block
      def intelligent_eval(block)
        if block.arity > 0
          block.call(self)
        else
          scope = ::Chopped::CombinedScope.new(self)
          scope.evaluate(block)
        end
      end

      # methods are prefixed with underscores to prevent conflicting with
      # actual NGINX directive names.
      def _push(item)
        children.push(item)
      end

      def _render
        # this flatten(1) is needed to keep block titles from over-indenting
        children.map { |c| c._render }.flatten(1)
      end

      # should s/block/context/g - a block is an NGINX context.
      # it looks like this:
      # block title {
      #   block child
      #   block child 2
      #   ...
      # }
      def _context(*title, &dsl_block)
        blk = ::Chopped::Nginx::AST::Context.new(title, [], &dsl_block)
        _push(blk)
      end

      # aka directive
      def _directive(title, *values)
        _push(::Chopped::Nginx::AST::Directive.new(title, values))
      end

      def comment(text)
        _push(::Chopped::Nginx::AST::Comment.new(text))
      end
    end # end DSL
  end
end
