# Git

## git clone `git@github.com:kubernetes/kubernetes.git`

## Start your idea on a new branch

```bash
$git checkout -b brilliant_idea origin/master

$vim or emacs

$git add .

$git commit

$git push origin/brilliant_idea
```

## GitHub code review

- create a PR from your branch to official master branch
- wait for `/LGTM` or rejected
- fix the comments or close the PR

## Daily workflow good practice

- commit often
- squash to be atomic commit, which means this commit can be reverted safely
- one branch one idea
- run tests on local first and keep everything simple and clear
- don't be clever
