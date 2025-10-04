# teams approved but not yet created:
# * missing email validation step?
# * invalid OSN account
library(conflicted)
library(tidyverse)
library(here)
library(fs)

conflicts_prefer(dplyr::filter)

here("R", "helpers.R") |> source()

get_teams_raw() |> get_teams_limbo()
