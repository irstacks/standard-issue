# Git ignore stuff that wasn't ignore before. 
```
# add whatever to .gitignore
__pycache__/
```

> So if you want add to ignore some directories in your local repository (which already exist) after editing .gitignore you want to run this on your root dir

```
$ git rm --cached -r .
$ git add .
```