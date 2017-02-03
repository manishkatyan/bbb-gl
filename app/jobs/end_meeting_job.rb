# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class EndMeetingJob < ApplicationJob
  include BbbApi

  queue_as :default

  def perform(room, meeting)
    tries = 0
    sleep_time = 2

    while tries < 4
      bbb_res = bbb_get_meeting_info("#{room}-#{meeting}")

      if !bbb_res[:returncode]
        ActionCable.server.broadcast "#{room}-#{meeting}_meeting_updates_channel",
          action: 'meeting_ended'
        break
      end

      sleep sleep_time
      sleep_time = sleep_time * 2
      tries += 1
    end

  end
end