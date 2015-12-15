class AttendanceController < ApplicationController
  def home
    @next_rehearsal = Rehearsal.where('start_date > ?', DateTime.now).order('start_date ASC').first
    @prev_rehearsal = Rehearsal.where('start_date < ?', DateTime.now).order('start_date DESC').first
  end

  def list
    @performers = []
    @records = {}
    Registration.current.order(:chorus_number).each do |registration|
      performer = registration.performer.attributes
      @records[performer['id']] = {}
      performer['chorus_number'] = registration.chorus_number
      @performers << performer
    end
    @rehearsals = Concert.current.rehearsals.order(:start_date)

    AttendanceRecord.where(:performer => @performers.map{|performer| performer['id']}, :rehearsal => @rehearsals).each do |record|
      @records[record.performer.id][record.rehearsal.id] = record
    end
  end
end
