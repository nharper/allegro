class CardsController < ApplicationController
  def new
    # Select registrations (with associated performer model) for performers
    # that don't have cards.
    @registrations = Registration.where(:concert => Concert.current).where.not(:performer_id => Card.where(:active => true).pluck(:performer_id)).includes(:performer).order('chorus_number')
    # @performers = Performer.where.not(:id => Card.where(:active => true).pluck(:performer_id))
  end

  def create
    card = Card.create(params[:card].permit(:card_id, :performer_id).merge(:active => true))
    if !card.valid?
      flash[:error] = 'Error creating new card'
    end
    redirect_to new_card_path
  end

  def index
    respond_to do |format|
      format.html do
        @cards = Card.all.includes(:performer).order('performers.name')
      end
      format.json do
        @cards = Card.select(:card_id, :performer_id).where(:active => true)
        render :json => @cards
      end
    end
  end

  def destroy
    card = Card.find(params[:id])
    if !card.destroy
      flash[:error] = 'Error deleting card'
    end
    redirect_to new_card_path
  end
end
