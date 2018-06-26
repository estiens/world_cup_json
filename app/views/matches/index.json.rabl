# frozen_string_literal: true

collection @matches, object_root: false
cache @matches, expires_in: @cache_time
extends 'matches/match'
