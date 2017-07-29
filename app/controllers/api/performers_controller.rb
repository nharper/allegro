class Api::PerformersController < ApplicationController
  def index
    @performers = Performer.all
    performers = []
    @performers.each do |performer|
      performers << {
        id: performer.id,
        name: performer.name,
        photo_path: photo_performer_path(performer),
      }
    end
    render :json => performers
  end
end
