# autopep8
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-autopep8-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/autopep8)

A GitHub action for [autopep8](https://github.com/hhatto/autopep8), a tool that automatically formats Python code to conform to the PEP 8 style guide.

This action is designed to be used in conjunction with [Create Pull Request](https://github.com/peter-evans/create-pull-request). This will automatically create a pull request to merge fixes that autopep8 makes to python code in your repository.

## Usage

This action is a simple wrapper around [autopep8](https://github.com/hhatto/autopep8). Arguments should be passed to the action via the `args` parameter.
This example fixes all python files in your repository with aggressive level 2.

```yml
    - name: autopep8
      uses: peter-evans/autopep8@v1.0.0
      with:
        args: --recursive --in-place --aggressive --aggressive .
```

See [autopep8 documentation](https://github.com/hhatto/autopep8) for further argument details.

#### Automated pull requests

On its own this action is not very useful. Please use it in conjunction with [Create Pull Request](https://github.com/peter-evans/create-pull-request), as in the following example.

```yml
name: Format python code
on: push
jobs:
  autopep8:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: autopep8
      uses: peter-evans/autopep8@v1.0.0
      with:
        args: --recursive --in-place --aggressive --aggressive .
    - name: Create Pull Request
      uses: peter-evans/create-pull-request@v1.5.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        COMMIT_MESSAGE: autopep8 action fixes
        PULL_REQUEST_TITLE: Fixes by autopep8 action
        PULL_REQUEST_BODY: This is an auto-generated PR with fixes by autopep8.
        PULL_REQUEST_LABELS: autopep8, automated pr
        PULL_REQUEST_REVIEWERS: peter-evans
        PULL_REQUEST_BRANCH: autopep8-patches
```

The workflow in this repository created [this sample pull request](https://github.com/peter-evans/autopep8/pull/11).

## License

MIT License - see the [LICENSE](LICENSE) file for details
