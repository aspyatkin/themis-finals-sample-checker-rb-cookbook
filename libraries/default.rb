require 'etc'

module ChefCookbook
  module Themis
    module Finals
      module Service1
        class Helper
          def initialize(node)
            @id = 'themis-finals-service1-checker'
            @node = node
          end

          def fqdn
            @node[@id]['fqdn'].nil? ? @node['automatic']['fqdn'] : @node[@id]['fqdn']
          end
        end
      end
    end
  end
end
