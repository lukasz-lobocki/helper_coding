# CODING

```bash
git clone git@github.com:lukasz-lobocki/<...>
```

```bash
git pull origin main
```

```bash
git add --update \
  && git commit -m "Update" \
  && git push origin main
```

<details>
<summary>Advanced</summary>

```bash
git clone --recurse-submodules git@github.com:lukasz-lobocki/<...>
```

```bash
git fetch origin main
```

```bash
git add --all
```

```bash
git push --set-upstream origin main
```

Delete all spaces at end of the line of text. See [here](https://linuxhint.com/50_sed_command_examples/#s14).

```bash
sed 's/[[:blank:]]*$//' <file>
```

</details>

## Poetry

### Basic versioning

Check [Poetry](https://blog.frank-mich.com/poetry-explanations-and-tips/), or [py-pkgs](https://py-pkgs.org/07-releasing-versioning), or [python-semantic-release](https://python-semantic-release.readthedocs.io/en/latest/configuration.html) pages.

```bash
git add --update
```

```bash
git commit -m "fix: change"
```

```bash
poetry run semantic-release version
```

```bash
git push
```

<details>
<summary>Arbitrary bump.</summary>

If you need to bump the version to an arbitrary number, add `git tag` with the value _preceding_ the desired one. If you need version `v0.3.2`, use `git tag v0.3.1` and perform _patch_ level `fix:` commit.

```bash
git tag --annotate v0.3.1 -m "Manual version bump."
```

```bash
git add --update \
  && git commit -m "fix: Manual version bump."
```

```bash
poetry run semantic-release version
```

</details>

### Placement of virtualenvs

```bash
poetry config virtualenvs.in-project true
```

```bash
poetry config virtualenvs.create true
```
<details>
<summary>New in new directory</summary>

#### Script

Check out this script [file-module_setup-sh](https://github.com/lukasz-lobocki/helper_coding/blob/main/other/setup_module.sh), alternatively create via PyCharm _NEW_ project.

#### Add

```bash
poetry add --group dev esptool
```

```bash
poetry add --editable git++ssh://github.com/lukasz-lobocki/lobo_rig.git
```

#### Linking src

```bash
find .venv/src/*/src/* \
  -type f \( -iname '*.py' ! -iname '__init__.py' \) \
  -print0 \
  | xargs -0I@ ln --relative --symbolic @ sub
```

</details>

### Recreating environment

Do the following in the folder with `pyproject.toml`.

Stop the current virtualenv, if active. Alternatively use `exit` to exit from a Poetry shell session. Remove all files of the current environment of the folder you are in, then reactivate Poetry shell.

```bash
deactivate \
   ; POETRY_LOCATION=$(poetry env info -p) \
  && echo "Poetry is $POETRY_LOCATION" \
  && rm -rf "$POETRY_LOCATION" \
  && poetry shell
```

Install everything.

```bash
poetry install --no-interaction
```

## PyPI

Check [this](https://packaging.python.org/en/latest/tutorials/packaging-projects/) page.

### Preparation

Build _sdist_ and _wheel_.

```bash
poetry build
```

Adding uploader, needed **only** if you do not have one already.

```bash
poetry add --group dev twine
```

### Upload to testPyPI

```bash
poetry run twine upload --repository testpypi dist/*
```

### Upload to PyPI - the *production*

```bash
poetry run twine upload dist/*
```

### Download from PyPI and testPyPI

Primary source dedinition.

```bash
poetry source add --priority=primary PyPI
```

Supplemental source definition.

```bash
poetry source add --priority=supplemental testpypi https://test.pypi.org/simple/
```

And then, add module the same way as other's modules.

```bash
poetry add <module-name>
```

```bash
poetry update
```

## Gita

Check [gita](https://github.com/nosarthur/gita) page.

### Add

All repo(s) in <repo-parent-path(s)> recursively

```bash
gita add -r <repo-parent-path(s)>
```

<details>
<summary>Same as above plus automatically generate hierarchical groups.</summary>

```bash
gita add -a <repo-parent-path(s)>
```

</details>

### Remove

All groups and repos

```bash
gita clear
```

### List repos by last commit date

With working tree.

```bash
gita shell \
  "{ \
    git log --pretty=format:'^%ct^%cr^' --date-order -n 1; \
    git rev-parse --show-toplevel \
      | tr -d '\n'; \
    git branch -v \
      | grep -o '\[[^]]*\]' \
      | sed 's/^/\^/'; \
  };" \
  | grep --invert-match '^$' \
  | sort --ignore-leading-blanks --field-separator='^' --key=2 --reverse \
  | cut --delimiter='^' --fields=2 --complement \
  | column --table --separator '^' --output-separator '  ' \
    --table-columns 'Repo,Last commit,Working tree,Ahead/behind'
```

With Github link.

```bash
gita shell \
  "{ \
    git log --pretty=format:'^%ct^%cr^' --date-order -n 1; \
    git config --get remote.origin.url \
      | tr -d '\n' \
      | sed 's/^git@github.com:/ssh@https:\/\/github.com\//'; \
    git branch -v \
      | grep -o '\[[^]]*\]' \
      | sed 's/^/\^/'; \
  };" \
  | grep --invert-match '^$' \
  | sort --ignore-leading-blanks --field-separator='^' --key=2 --reverse \
  | cut --delimiter='^' --fields=2 --complement \
  | column --table --separator '^' --output-separator '  ' \
    --table-columns 'Repo,Last commit,Github,Ahead/behind'
```

## Detached head

```bash
git commit -m "my temp work, head reatachment" && git branch temp
```

```bash
git checkout main && git merge temp
```

## Delete remote branch

```bash
git branch --remotes
```

```bash
git push origin --delete wip
```

```bash
git fetch --prune origin
```

## Switch to ssh

```bash
git remote --verbose ; git remote rm origin
```

```bash
git remote add origin \
  git@github.com:lukasz-lobocki/transmitter_bme_nrf.git
```

```bash
git remote --verbose
```

```bash
git fetch origin ; git push --set-upstream origin main
```

## Purging

Make the current commit the only (initial) commit in a Git repository.

:warning: It is mandatory to **do backup**.

:information_source: Requires `main` branch **not protected**, see this [page](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches).

```bash
git checkout --orphan newBranch \
  && git add --all
  && git commit
```

```bash
git branch --delete --force main \
  && git branch --move main \
  && git push --force origin main
```

```bash
git reflog expire --expire=now --all  # expire reflog to dereference objects
```

```bash
git gc --aggressive --prune=now  # remove the old files
```

## Subs

<details>
<summary>Subs.</summary>

## Submodules

Check [this](https://gist.github.com/gitaarik/8735255#file-git_submodules-md) page.

```bash
git submodule add git@github.com:lukasz-lobocki/lobo_rig git-submodule/lobo_rig
```

To update the submodule.

```bash
git submodule update --remote
```


## Subtrees

Check [this](https://gist.github.com/SKempin/b7857a6ff6bddb05717cc17a44091202#file-git-subtree-basics-md) page.

### Add

```bash
git subtree add --prefix git-subtree/lobo_rig git@github.com:lukasz-lobocki/lobo_rig main --squash
```

### Pull in new subtree commits

If you want to pull in any new commits to the subtree from the remote, issue the same command as above, replacing `add` for `pull`:

`git subtree pull --prefix git-subtree/lobo_rig git@github.com:lukasz-lobocki/lobo_rig master --squash`


### Updating / Pushing to the subtree remote repository

If you make a change to anything in `git-subtree/lobo_rig` the commit will be stored in the **host repository** and its logs. That is the biggest change from submodules.

If you now want to update the subtree remote repository with that commit, you must run the same command, **excluding** `--squash` and replacing `pull` for `push`.

`git subtree push --prefix git-subtree/lobo_rig git@github.com:lukasz-lobocki/lobo_rig master`

### Troubleshoot

```bash
git diff-index HEAD
```

### List

```bash
git log | grep git-subtree-dir | tr -d ' ' | cut -d ":" -f2 | sort | uniq
git log | grep git-subtree-dir | awk '{ print $2 }'
```

### Document

```bash
git remote --verbose > .gitremote && git log \
  | grep git-subtree-dir \
  | tr -d ' ' | cut -d ":" -f2 \
  | sort | uniq \
  | xargs -I {} bash -c 'if [ -d $(git rev-parse --show-toplevel)/{} ] ; then echo {}; fi' \
  > .gitsubtree
```

## requirements.txt

```bash
pipreqs --print
```

</details>

## rshell

To connect.

```bash
rshell --port /dev/ESP32_S3_pro
```

To remove a directory.

```bash
rshell --port /dev/ESP32_S3_pro rm -r /sub
```

To do the do.

```bash
rshell ls /pyboard
```

```bash
rshell cp -r lobo_rig /pyboard/flash/lib
```

```bash
rshell rsync . /pyboard/flash/lib
```

## ampy

To run using poetry's venv.

```bash
poetry run ampy
```

```bash
poetry run ampy --port /dev/ESP32_S3_pro ls
```
