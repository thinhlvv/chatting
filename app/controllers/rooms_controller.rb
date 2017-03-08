class RoomsController < ApplicationController
  def index
		@room = Room.new
  end

  def create
		@room = Room.new room_params
		if !@room.save
			p @room.errors.full_messages	
			flash[:error] = @room.errors.full_messages.to_sentence
		else
			flash[:success] = 'Create room successfully!'	
		end
  end

  def new
  end
	
	private 
		def room_params
			params.require(:room).permit(:name)
		end
end
