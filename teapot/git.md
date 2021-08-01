# Git

## git clone `git@github.com:kubernetes/kubernetes.git`

## Start your idea on a new branch

```bash
$ git checkout -b brilliant_idea origin/master  ;; checkout yourown branch from master to work on
$ vim or emacs                                  ;; make your idea into realiaty
$ git add .
$ git commit                                    ;; write good commit message will make you PR better reviewed
$ git push origin/brilliant_idea                ;; push to github and create PR
```

## GitHub Code Review

- create a PR from your branch to official master branch
- wait for `/LGTM` or rejected
- fix the comments or discard the PR

## Daily workflow good practice

- commit often
- squash to be atomic commit, which means this commit can be reverted safely
- one branch one idea
- run tests on local first and keep everything simple and clear
- don't be clever
