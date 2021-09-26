# Git Init
```
git init
git config user.name "Wilton Carvalho"
git config user.email root@wiltoncarvalho.com
git add README.md
git commit -m "first commit"
git remote add origin ssh://git@github.com/WiltonCarvalho/devops.git
git push -u origin master
```
# Creates a signed commit
```
git add .
gpg --list-secret-keys --keyid-format LONG | grep sec
git config user.signingkey B1DFF6D400B715EC
git commit -S -m "your commit message"
git push
```