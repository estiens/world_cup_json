class JsonMatch
  class PlayersFormatter
    class << self
      def players_from_array(players_array)
        create_players_from_match_info(players_array)
      end

      def player_from_hash(player_hash)
        create_player_from_info_hash(player_hash)
      end

      def create_players_from_match_info(array)
        return [] unless array.is_a? Array

        array.map { |player| create_player_from_info_hash(player) }
      end

      def create_player_from_info_hash(player)
        name = player&.dig('PlayerName')&.first&.dig('Description')&.titlecase
        captain = player&.dig('Captain')
        shirt_number = player&.dig('ShirtNumber')
        position = get_position_from(player&.dig('Position'))
        fifa_id = player&.dig('IdPlayer')
        { name:, captain:, shirt_number:, position:, fifa_id: fifa_id }
      end

      def get_position_from(position)
        return nil unless position

        return 'Goalkeeper' if position.to_i.zero?
        return 'Defender' if position.to_i == 1
        return 'Midfielder' if position.to_i == 2
        return 'Forward' if position.to_i == 3

        'Unknown'
      end
    end
  end
end
