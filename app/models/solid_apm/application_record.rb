module SolidApm
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.connects_to **SolidApm.connects_to
  end
end
