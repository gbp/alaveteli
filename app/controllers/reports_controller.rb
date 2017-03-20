# -*- encoding : utf-8 -*-
class ReportsController < ApplicationController
  before_filter :set_info_request

  def create
    @reason = params[:reason]
    @message = params[:message] || ""
    if @reason.empty?
      flash[:error] = _("Please choose a reason")
      render "new"
      return
    end
    if !authenticated_user
      flash[:notice] = _("You need to be logged in to report a request for administrator attention")
    elsif @info_request.attention_requested
      flash[:notice] = _("This request has already been reported for administrator attention")
    else
      @info_request.report!(@reason, @message, @user)
      flash[:notice] = _("This request has been reported for administrator attention")
    end
    redirect_to request_url(@info_request)
  end

  def new
    if authenticated?(
        :web => _("To report this request"),
        :email => _("Then you can report the request '{{title}}'", :title => @info_request.title),
      :email_subject => _("Report an offensive or unsuitable request"))
    end
  end

  private

  def set_info_request
    @info_request = InfoRequest
                      .not_embargoed
                        .find_by_url_title!(params[:request_id])
  end

end
