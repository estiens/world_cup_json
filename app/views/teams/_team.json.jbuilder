# frozen_string_literal: true

json.call(team, :id, :country, :alternate_name, :fifa_code,
          :group_id)
json.group_letter team.group.letter
