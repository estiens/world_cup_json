json.cache! team, expires_in: 1.minute do
  json.(team, :id, :country, :alternate_name, :fifa_code,
              :group_id)
  json.group_letter team.group.letter
end
