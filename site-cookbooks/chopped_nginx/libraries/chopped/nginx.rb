module Chopped
  module Nginx
    def self.test
      conf_str = Chopped::Nginx.config do
        user 'foo bar'
        worker_processes 5

        server :dog do
          root :jackie
          satisfy 55
        end

        server :cat do
          root :rat
          satisfy :face
          queue '"what"'
        end
      end # end config do
      puts conf_str
    end # end test
  end
end

require_relative './nginx/ast'
require_relative './nginx/dsl'
require_relative './nginx/config'
require_relative './nginx/helper'
