#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.

require "spec_helper"

RSpec.describe "GET /api/v3/users" do
  let!(:users) do
    [
      create(:admin, login: "admin", status: :active),
      create(:user, login: "h.wurst", status: :active),
      create(:user, login: "h.heine", status: :locked),
      create(:user, login: "m.mario", status: :active)
    ]
  end

  before do
    login_as users.first
  end

  def filter_users(name, operator, values)
    filter = {
      name => {
        "operator" => operator,
        "values" => Array(values)
      }
    }
    params = {
      filters: [filter].to_json
    }

    get "/api/v3/users", params

    json = JSON.parse last_response.body

    Array(Hash(json).dig("_embedded", "elements")).map { |e| e["login"] }
  end

  describe "status filter" do
    it "=" do
      expect(filter_users("status", "=", :active)).to contain_exactly("admin", "h.wurst", "m.mario")
    end

    it "!" do
      expect(filter_users("status", "!", :active)).to contain_exactly("h.heine")
    end
  end

  describe "login filter" do
    it "=" do
      expect(filter_users("login", "=", "admin")).to contain_exactly("admin")
    end

    it "!" do
      expect(filter_users("login", "!", "admin")).to contain_exactly("h.wurst", "h.heine", "m.mario")
    end

    it "~" do
      expect(filter_users("login", "~", "h.")).to contain_exactly("h.wurst", "h.heine")
    end

    it "!~" do
      expect(filter_users("login", "!~", "h.")).to contain_exactly("admin", "m.mario")
    end
  end
end
