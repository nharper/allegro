class AttendanceController < ApplicationController
  def home
    @concerts = Concert.active
    @next_rehearsal = Rehearsal.where('start_date > ?', DateTime.now).order('start_date ASC').first
    @prev_rehearsal = Rehearsal.where('start_date < ?', DateTime.now).order('start_date DESC').first
  end
end
