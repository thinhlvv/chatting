class RoomsController < ApplicationController
  def index
		@rooms = Room.all
		@room = Room.new
  end

  def create
		@room = Room.new room_params
		if !@room.save	
			flash[:error] = @room.errors.full_messages.to_sentence
			redirect_to root_path
		else
			flash[:success] = 'Create room successfully!'	
			redirect_to root_path
		end
  end

  def new
  end
	
	private 
		def room_params
			params.require(:room).permit(:name)
		end
end
