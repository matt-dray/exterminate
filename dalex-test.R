# Investigating DALEX and modelDown with baseball pitch data
# Matt Dray
# Jan 2019


# Prepare workspace -------------------------------------------------------


library("readr")
library("dplyr")

library("DALEX")
library("modelDown")


# Data --------------------------------------------------------------------


pitches <- read_csv(
  file = "data/pitches.csv", 
  col_types = cols(ab_id = col_character())
)

atbats <- read_csv(
  file = "data/atbats.csv",
  col_types = cols(
    ab_id = col_character(),
    g_id = col_character(),
    pitcher_id = col_character(),
    batter_id = col_character()
  )
)

games <- read_csv(
  file = "data/games.csv",
  col_types = cols(g_id = col_character())
)

# Join datasets
# To get dates for pitches we need to join 'games' to 'pitches' via 'atbats'
pitch <- 
  pitches %>% 
  left_join(y = atbats, by = "ab_id") %>% 
  left_join(y = games, by = "g_id") %>% 
  select(
    # identifiers
    g_id, ab_id, pitcher_id, batter_id,  # game, at-bat and batter
    # outcome
    type, code, event, # type is simplified to S (strike), B (ball), X (in play)
    # game information
    home_team, away_team,
    # play state
    inning, top, # which inning and whether top or bottom
    p_score,  # score for pitcher's team at time of pitch
    outs,  # number of outs before pitch is thrown
    on_1b, on_2b, on_3b,  # on base
    # pitch characteristics
    pitch_type,  # type of pitch
    pitch_num,  # pitch number of at-bat
    p_throws,  # which hand the pitcher throws with
    px, pz,  # location at plate (x=0 down the middle, z=0 the ground)
    spin_dir, spin_rate,  # spin direction and speed
    start_speed, end_speed  # speed of pitch 
  ) %>% 
  filter(!is.na(px))  # data is missing for ~14k