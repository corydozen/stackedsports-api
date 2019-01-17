class CoEmailGroupingsController < ApplicationController
  # skip_before_action :require_login

  private

    def co_email_grouping_params
      params.require(:co_email_grouping).permit(:description)
    end
end
