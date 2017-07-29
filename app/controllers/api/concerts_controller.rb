class Api::ConcertsController < Api::BaseController
  def index
    @concerts = Concert.all
    render :json => @concerts
  end
end
