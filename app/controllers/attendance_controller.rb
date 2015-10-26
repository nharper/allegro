class AttendanceController < ApplicationController
  def home
    @next_rehearsal = Rehearsal.where('start_date > ?', DateTime.now).order('start_date ASC').first
    @prev_rehearsal = Rehearsal.where('start_date < ?', DateTime.now).order('start_date DESC').first
  end

  def list
    @registrations = Registration.current.order(:chorus_number)
    @rehearsals = Concert.current.rehearsals.order(:start_date).index_by(&:id)
    @performers = []
    @records = {}
    @registrations.each do |registration|
      @performers << registration.performer
      @records[registration.performer.id] = {}
    end
    AttendanceRecord.where(:performer => @performers, :rehearsal => @rehearsals.values).each do |record|
      @records[record.performer.id][record.rehearsal.id] = record
    end
  end
end
