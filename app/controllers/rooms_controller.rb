class RoomsController < ApplicationController
  def index
    if params[:keyword].present?
      slideshare = Slideshare.search(params[:keyword])
      @slides = slideshare.slides
    else
      @slides = []
    end
  end
end
