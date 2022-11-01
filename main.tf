locals {
  grafana_access = jsondecode(file("config.json")).grafana-access

  grafana_teams_users = flatten([
    for team_key, team in local.grafana_access : [
      for user_key, user in team.users : {
        team = team
        user = user
      }
    ]
  ])

  grafana_teams = {for x in local.grafana_access : x.team => x.users}
  grafana_users = toset([for x in local.grafana_teams_users : x.user])
}

data "grafana_cloud_stack" "stack" {
  provider = grafana.cloud
  slug = "jackluo"
}

resource "grafana_api_key" "management" {
  provider = grafana.cloud

  cloud_stack_slug = data.grafana_cloud_stack.stack.slug
  name             = "management-key-tf"
  role             = "Admin"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "grafana_user" "users" {
  provider = grafana.basic
  for_each = local.grafana_users

  email    = each.key
  password = random_password.password.result
}

resource "grafana_team" "teams" {
  provider = grafana.stack
  for_each = local.grafana_teams

  name  = each.key
  members = each.value
}
