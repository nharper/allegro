class AttendanceController < ApplicationController
  # TODO(nharper): implement index and show methods

  def section
    # TODO(nharper): use real rehearsal, section objects
    @rehearsal = params['rehearsal']
    @section = params['section']

    @performers = Performer.select('id, name, number, section').where(:section => params['section'].upcase)
  end

  def update
    # TODO(nharper): Implement update
    redirect_to section_attendance_url(params['rehearsal'], params['section'])
  end
end
