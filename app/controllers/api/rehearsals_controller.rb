class Api::RehearsalsController < Api::BaseController
  def index
    @rehearsals = Rehearsal.all
    render :json => @rehearsals
  end
end
