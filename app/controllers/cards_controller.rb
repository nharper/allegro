class CardsController < ApplicationController
  def new
    @performers = Performer.where.not(:id => Card.where(:active => true).pluck(:performer_id))
  end

  def create
    if !Card.create(params[:card].permit(:card_id, :performer_id).merge(:active => true))
      flash[:error] = 'Error creating new card'
    end
    redirect_to cards_path
  end

  def index
    respond_to do |format|
      format.html do
        @cards = Card.all.includes(:performer).order(:active => :desc)
      end
      format.json do
        @cards = Card.select(:card_id, :performer_id).where(:active => true)
        render :json => @cards
      end
    end
  end
end
