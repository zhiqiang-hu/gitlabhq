# frozen_string_literal: true

module BulkImports
  module Groups
    module Transformers
      class SubgroupsToEntitiesTransformer
        def initialize(*args); end

        def transform(context, data)
          data.map do |entry|
            {
              source_type: :group_entity,
              source_full_path: entry['full_path'],
              destination_name: entry['name'],
              destination_namespace: context.entity.group.full_path,
              parent_id: context.entity.id
            }
          end
        end
      end
    end
  end
end
