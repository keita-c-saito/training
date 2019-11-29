# frozen_string_literal: true

FactoryBot.define do
  factory :maintenance_config, class: Config do
    name { 'maintenance' }
    enabled { 'off' }
  end
end
