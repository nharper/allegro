class ConcertsController < ApplicationController
  def rehearsals
    @concert = Concert.find(params[:id])
    @breadcrumbs = ["Rehearsals (#{@concert.name})"]
    @rehearsals = Rehearsal.where(:concert => @concert).order('start_date ASC')
    render :template => 'rehearsals/index'
  end

  def attendance
    @concert = Concert.find(params[:id])
    render 'empty_list' and return unless @concert

    @sections = Registration::SECTION_TO_FULL
    @performers = []
    @records = {}
    Registration.where(:concert => @concert, :status => 'active').includes(:performer).order(:chorus_number).each do |registration|
      performer = registration.performer.attributes
      performer['registration_id'] = registration.id
      performer.delete('photo')
      @records[performer['id']] = {}
      performer['chorus_number'] = registration.chorus_number
      performer['section'] = registration.section_from_number
      @performers << performer
    end
    @rehearsals = @concert.rehearsals.order(:start_date)

    AttendanceRecord.where(:performer => @performers.map{|performer| performer['id']}, :rehearsal => @rehearsals).each do |record|
      @records[record.performer_id][record.rehearsal_id] = record
    end
  end

  def audit
    @concert = Concert.find(params[:id])
    @registrations = Registration.where(:concert => @concert).includes(:performer)
    @bad_registrations = []

    @registrations.each do |reg|
      cn = reg.chorus_number.to_i
      if cn < 100 || cn > 499
        @bad_registrations << [reg, "CN out of range"]
        next
      end
      if reg.section_from_number != reg.section
        @bad_registrations << [reg, "Mismatch"]
        next
      end
    end
  end

  def index
    @concerts = Concert.all.order(:start_date)
  end
end
