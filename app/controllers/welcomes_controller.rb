class WelcomesController < ApplicationController
  skip_before_action :require_login

  def show
    respond_to do |format|
        format.html { render 'welcome' }
        format.json { render  'Welcome to the Stacked Sports Api', status: :ok }
    end
  end

end
