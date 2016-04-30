# TODO: move to its own gem? put the chopped gem in a gems/ folder at the top of
# the monorepo? I think that makes sense -- then there is one shared ruby
# codebase that all our site-cookbooks depend upon....
module Chopped
end

require_relative './chopped/block_property_support'
require_relative './chopped/combined_scope'
require_relative './chopped/nginx'
