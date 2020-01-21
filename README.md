# autopep8
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-autopep8-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/autopep8)

A GitHub action for [autopep8](https://github.com/hhatto/autopep8), a tool that automatically formats Python code to conform to the PEP 8 style guide.

This action is designed to be used in conjunction with [Create Pull Request](https://github.com/peter-evans/create-pull-request). This will automatically create a pull request to merge fixes that autopep8 makes to python code in your repository.

## Usage

This action is a simple wrapper around [autopep8](https://github.com/hhatto/autopep8). Arguments should be passed to the action via the `args` parameter.
This example fixes all python files in your repository with aggressive level 2.

```yml
      - name: autopep8
        id: autopep8
        uses: peter-evans/autopep8@v1
        with:
          args: --recursive --in-place --aggressive --aggressive .
```

The action outputs the exit code from autopep8. This can be useful in combination with the autopep8 flag `--exit-code` for pull request checks.

```yml
      - name: Fail if autopep8 made changes
        if: steps.autopep8.outputs.exit-code == 2
        run: exit 1
```

See [autopep8 documentation](https://github.com/hhatto/autopep8) for further argument details.

## Automated pull requests

On its own this action is not very useful. Please use it in conjunction with [Create Pull Request](https://github.com/peter-evans/create-pull-request) or a [direct push to branch workflow](https://github.com/peter-evans/autopep8#direct-push-with-on-pull_request-workflows).

The following workflow is a simple example to demonstrate how the two actions work together.

```yml
name: Format python code
on: push
jobs:
  autopep8:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: autopep8
        uses: peter-evans/autopep8@v1
        with:
          args: --recursive --in-place --aggressive --aggressive .
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: autopep8 action fixes
          committer: Peter Evans <peter-evans@users.noreply.github.com>
          title: Fixes by autopep8 action
          body: This is an auto-generated PR with fixes by autopep8.
          labels: autopep8, automated pr
          reviewers: peter-evans
          branch: autopep8-patches
```

This configuration will create pull requests that look like this:

![Pull Request Example](https://github.com/peter-evans/autopep8/blob/master/autopep8-example-pr.png?raw=true)

## Automated pull requests with "on: pull_request" workflows

**Update**: While the following approach does work in some cases, my strong recommendation would be to use a slash command style "ChatOps" solution for operations on pull requests. See [slash-command-dispatch](https://github.com/peter-evans/slash-command-dispatch) for such a solution.

The following is an example workflow for a use-case where autopep8 runs as both a check on pull requests and raises a further pull request to apply fixes.

How it works:
1. When a pull request is raised the workflow executes as a check.
2. If autopep8 makes any fixes a pull request will be raised for those fixes to be merged into the current pull request branch. The workflow then deliberately causes the check to fail.
3. When the pull request containing the fixes is merged the workflow runs again. This time autopep8 makes no changes and the check passes.
4. The original pull request can now be merged.

Note that due to [limitations on forked repositories](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/authenticating-with-the-github_token#permissions-for-the-github_token) this workflow does not work for pull requests raised from forks.

```yml
name: autopep8
on: pull_request
jobs:
  autopep8:
    # Check if the PR is not raised by this workflow and is not from a fork
    if: startsWith(github.head_ref, 'autopep8-patches') == false && github.event.pull_request.head.repo.full_name == github.repository
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: autopep8
        id: autopep8
        uses: peter-evans/autopep8@v1
        with:
          args: --exit-code --recursive --in-place --aggressive --aggressive .
      - name: Set autopep8 branch name
        id: vars
        run: echo ::set-output name=branch-name::"autopep8-patches/$GITHUB_HEAD_REF"
      - name: Create Pull Request
        if: steps.autopep8.outputs.exit-code == 2
        uses: peter-evans/create-pull-request@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: autopep8 action fixes
          committer: Peter Evans <peter-evans@users.noreply.github.com>
          title: Fixes by autopep8 action
          body: This is an auto-generated PR with fixes by autopep8.
          labels: autopep8, automated pr
          reviewers: peter-evans
          branch: ${{ steps.vars.outputs.branch-name }}
      - name: Fail if autopep8 made changes
        if: steps.autopep8.outputs.exit-code == 2
        run: exit 1
```

## Direct push with "on: pull_request" workflows

The following workflow is an alternative to the previous workflow. Instead of raising a second pull request it commits the changes made by autopep8 directly to the pull request branch.

**Important caveat:** If you have other pull request checks besides the following workflow then you must use a [Personal Access Token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line) instead of the default `GITHUB_TOKEN`.
This is due to a deliberate limitation imposed by GitHub Actions that events raised by a workflow (such as `push`) cannot trigger further workflow runs.
This is to prevent accidental "infinite loop" situations, and as an anti-abuse measure.
Using a `repo` scoped [Personal Access Token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line) is an approved workaround. See [this issue](https://github.com/peter-evans/create-pull-request/issues/48) for further detail.

How it works:
1. When a pull request is raised the workflow executes as a check.
2. If autopep8 makes any fixes they will be committed directly to the current pull request branch.
3. The `push` triggers all pull request checks to run again.

Note that due to [limitations on forked repositories](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/authenticating-with-the-github_token#permissions-for-the-github_token) this workflow does not work for pull requests raised from forks.

```yml
name: autopep8
on: pull_request
jobs:
  autopep8:
    # Check if the PR is not from a fork
    if: github.event.pull_request.head.repo.full_name == github.repository
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          token: ${{ secrets.REPO_ACCESS_TOKEN }}
          ref: ${{ github.head_ref }}
      - name: autopep8
        id: autopep8
        uses: peter-evans/autopep8@v1
        with:
          args: --exit-code --recursive --in-place --aggressive --aggressive .
      - name: Commit autopep8 changes
        if: steps.autopep8.outputs.exit-code == 2
        run: |
          git config --global user.name 'Peter Evans'
          git config --global user.email 'peter-evans@users.noreply.github.com'
          git commit -am "Automated autopep8 fixes"
          git push
```

## License

MIT License - see the [LICENSE](LICENSE) file for details
