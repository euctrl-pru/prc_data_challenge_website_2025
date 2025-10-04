library(conflicted)
library(dplyr)
library(here)
library(purrrlyr)

conflicts_prefer(dplyr::filter)

here("R", "helpers.R") |> source()

teams_raw <- get_teams_raw()

teams_valid <- teams_raw |> get_teams_valid()

# members <- teams_raw |> get_teams_members()

#########################
# GENERATE Teams' pages #
#########################
teams_valid |>
  purrrlyr::by_row(generate_team_page)
