class FlavorTag < ApplicationRecord
  include TagCacheable

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end
end
