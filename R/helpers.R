library(conflicted)
library(googlesheets4)
library(googledrive)
library(tidyverse)
library(dplyr)
library(janitor)


# generate QMD page for one team
generate_team_page <- function(team, members = NULL) {
  page <- "
  ## {name}

  ### Description and Rationale
  {description}

  ### Details
  
  * Number of team members: {num}
  * Type: {type}
  * Affiliation: {affiliation}
  * Country: {country}

  "

  str_glue(
    page,
    name = team["team_name"],
    description = team["team_description"],
    affiliation = team["team_affiliation"],
    type = team["team_type"],
    country = team["team_country"],
    num = team["extra_members"] |> as.integer() |> magrittr::add(1L)
  ) |>
    write_lines(here("teams", paste0(team["team_name"], ".qmd")))
}


get_teams_members <- function(teams_raw) {
  teams_valid <- teams_raw |> get_teams_valid()
  teams_raw |>
    dplyr::filter(team_name %in% (teams_valid |> pull(team_name))) |>
    dplyr::select(team_name, matches("_\\d+$")) |>
    pivot_longer(
      cols = matches("_\\d+$"),
      names_to = c("attrib", "id"),
      names_pattern = "(.*)_(.*)",
      values_to = "val"
    ) |>
    pivot_wider(
      names_from = attrib,
      values_from = val
    ) |>
    filter(if_all(c(forename, surname, email), ~ !is.na(.x))) |>
    dplyr::mutate(id = as.integer(id)) |>
    arrange(team_name, id)
}

# teams approved but not yet created:
# * missing email validation step?
# * invalid OSN account
get_teams_limbo <- function(teams_raw) {
  teams_raw |>
    dplyr::filter(status == "approved", is.na(team_name)) |>
    dplyr::select(timestamp, forename_1, surname_1, email_1)
}

# get new teams requests to be assessed/approved
get_teams_new <- function(teams_raw) {
  teams_raw |>
    dplyr::filter(is.na(status), is.na(team_name)) |>
    dplyr::select(timestamp, forename_1, surname_1, email_1)
}

# get valid teams
get_teams_valid <- function(teams_raw) {
  teams_raw |>
    dplyr::filter(status == "approved", !is.na(team_name)) |>
    dplyr::select(-matches("_\\d+$"))
}

get_teams_all <- function(teams_raw) {
  teams_raw |>
    dplyr::select(-matches("_\\d+$"))
}

# just read the google sheet values from the submission form
get_teams_raw <- function() {
  teams_gsheet <- "1h25aKX68LTZNUH4dgJOnlOrhhByghA2hFuUr7WNl-vQ"
  googlesheets4::gs4_auth(
    email = "enrico.spinielli@gmail.com",
    scope = "https://www.googleapis.com/auth/drive"
  )
  googlesheets4::read_sheet(teams_gsheet, sheet = "better_colnames") |>
    dplyr::filter(
      !account %in%
        c("johnf-test2")
    ) |>
    dplyr::mutate(address_1 = unlist(address_1)) |>
    dplyr::relocate(
      timestamp,
      status,
      team_name,
      team_uuid,
      dplyr::everything(),
      matches("_\\d+$")
    )
}
