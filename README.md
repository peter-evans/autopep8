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
        uses: peter-evans/autopep8@v1.1.0
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

On its own this action is not very useful. Please use it in conjunction with [Create Pull Request](https://github.com/peter-evans/create-pull-request).

The following workflow is a simple example to demonstrate how the two actions work together.
You can see what the resulting pull request would look like from [this sample pull request](https://github.com/peter-evans/autopep8/pull/12).

```yml
name: Format python code
on: push
jobs:
  autopep8:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: autopep8
        uses: peter-evans/autopep8@v1.1.0
        with:
          args: --recursive --in-place --aggressive --aggressive .
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v1.5.2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          COMMIT_MESSAGE: autopep8 action fixes
          COMMIT_AUTHOR_EMAIL: peter-evans@users.noreply.github.com
          COMMIT_AUTHOR_NAME: Peter Evans
          PULL_REQUEST_TITLE: Fixes by autopep8 action
          PULL_REQUEST_BODY: This is an auto-generated PR with fixes by autopep8.
          PULL_REQUEST_LABELS: autopep8, automated pr
          PULL_REQUEST_REVIEWERS: peter-evans
          PULL_REQUEST_BRANCH: autopep8-patches
```

The following is an example workflow for a more realistic use-case where autopep8 runs as both a check on pull requests and raises a further pull request to apply fixes.

How it works:
1. When a pull request is raised the workflow executes as a check
2. If autopep8 makes any fixes a pull request will be raised for those fixes to be merged into the current pull request branch. The workflow then deliberately causes the check to fail.
3. When the pull request containing the fixes is merged the workflow runs again. This time autopep8 makes no changes and the check passes.
4. The original pull request can now be merged.

```yml
name: autopep8
on: pull_request
jobs:
  autopep8:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: autopep8
        id: autopep8
        uses: peter-evans/autopep8@v1.1.0
        with:
          args: --exit-code --recursive --in-place --aggressive --aggressive .
      - name: Create Pull Request
        if: steps.autopep8.outputs.exit-code == 2
        uses: peter-evans/create-pull-request@v1.5.2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          COMMIT_MESSAGE: autopep8 action fixes
          COMMIT_AUTHOR_EMAIL: peter-evans@users.noreply.github.com
          COMMIT_AUTHOR_NAME: Peter Evans
          PULL_REQUEST_TITLE: Fixes by autopep8 action
          PULL_REQUEST_BODY: This is an auto-generated PR with fixes by autopep8.
          PULL_REQUEST_LABELS: autopep8, automated pr
          PULL_REQUEST_REVIEWERS: peter-evans
          PULL_REQUEST_BRANCH: autopep8-patches
      - name: Fail if autopep8 made changes
        if: steps.autopep8.outputs.exit-code == 2
        run: exit 1
```

## License

MIT License - see the [LICENSE](LICENSE) file for details
