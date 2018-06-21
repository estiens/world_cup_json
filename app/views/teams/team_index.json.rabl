# frozen_string_literal: true

collection @teams, object_root: false
cache @teams, expires_in: 1.minute
attributes :id, :country, :alternate_name, :fifa_code, :group_id

node :group_letter do |team|
  team.group.letter
end
