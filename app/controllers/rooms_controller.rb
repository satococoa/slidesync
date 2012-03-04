class RoomsController < ApplicationController
  before_filter :require_login, except: :index

  def index
    if params[:keyword].present?
      slideshare = Slideshare.search(params[:keyword])
      @slides = slideshare.slides
    else
      @slides = []
    end
  end

  def create
    begin
      @slide = Slideshare.find(params[:slide_id])
      @room = current_user.rooms.create(
        slide_id: @slide.id,
        title: @slide.title,
        thumbnail: @slide.thumbnail,
        username: @slide.username,
        slide_url: @slide.doc,
        description: @slide.description
      )
      redirect_to @room
    rescue => e
      logger.error [e.class, e.message].join(' ')
      redirect_to :rooms, :error => e.message
    end
  end

  def show
    @room = Room.find(params[:id])
    if current_user != @room.user && !@room.guests.include?(current_user)
      if current_user.room.present?
        Pusher["room_#{current_user.room.id}"].trigger('exit', current_user)
      end
      @room.guests << current_user
      Pusher["room_#{@room.id}"].trigger('enter', current_user)
    end
  end

  def update
    @room = Room.find(params[:id])
    Pusher["room_#{@room.id}"].trigger('jump_to', params[:page])
    head :ok
  end
end
