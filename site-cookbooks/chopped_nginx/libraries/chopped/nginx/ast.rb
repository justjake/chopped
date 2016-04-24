module Chopped
  module Nginx
    # Represents the parts of an NGINX config
    module AST
      # base context. no wrapping. no indentation.
      class MainContext
        include DSL
        attr_reader :children

        def initialize(&block)
          @children = []

          if block_given?
            intelligent_eval(block)
          end
        end
      end # end Config

      # An NGINX context directive.
      # looks like
      #
      # title args {
      #   child
      #   child
      #   ...
      # }
      class Context < Struct.new('Context', :title, :children)
        include DSL

        def initialize(title, children = [], &block)
          super(title, children)
          if block_given?
            intelligent_eval(block)
          end
        end

        def _render
          title_s = (title + ['{']).join(' ')
          children_array = super
          close_s = '}'

          [title_s, children_array, close_s]
        end
      end # end Context

      # A regular NGINX directive.
      # looks like
      #
      # title value args;
      Directive = Struct.new('Directive', :title, :values) do
        def _render
          ([title] + values).join(' ') + ';'
        end
      end # end Directive

      # A comment in an NGINX config file.
      # looks like
      #
      # # some text
      Comment = Struct.new('Comment', :text) do
        def _render
          '# ' + text
        end
      end # end Comment
    end # end module AST
  end
end
