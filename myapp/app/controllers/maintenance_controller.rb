# frozen_string_literal: true

class MaintenanceController < ApplicationController
  skip_before_action :check_maintenance, :require_login

  def show
    render plain: t(:in_maintenance)
  end
end
