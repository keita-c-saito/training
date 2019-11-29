# frozen_string_literal: true

class Config < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  enum enabled: %i[off on]
end
