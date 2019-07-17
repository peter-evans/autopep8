workflow "Format python code" {
  resolves = ["Create Pull Request"]
  on = "schedule(0 0 1 1/12 *)"
}

action "autopep8" {
  uses = "./"
  args = "--recursive --in-place --aggressive --aggressive ."
}

action "Create Pull Request" {
  needs = "autopep8"
  uses = "peter-evans/create-pull-request@v1.0.0"
  secrets = ["GITHUB_TOKEN"]
  env = {
    PULL_REQUEST_BRANCH = "autopep8-patches"
    COMMIT_MESSAGE = "autopep8 action fixes"
    PULL_REQUEST_TITLE = "Fixes by autopep8 action"
    PULL_REQUEST_BODY = "This is an auto-generated PR with fixes by autopep8."
  }
}
