collection @teams, object_root: false
attributes :id, :country, :alternate_name, :fifa_code, :group_id

node :group_letter do |team|
  team.group.letter
end
