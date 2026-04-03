module SolidApm
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to(**SolidApm.connects_to) if SolidApm.enabled && SolidApm.connects_to
  end
end
