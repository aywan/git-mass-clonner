# GIT_MASS_CLONER

Simple script for cloning/fetching a lot of git repos.

Example:
```bash
echo "https://github.com/doctrine/common.git
git@github.com:symfony/symfony.git" | ./cloner.sh clone
```

For clone all php's `composer.lock` repos:
```bash
cat composer.lock | jq -r '.packages[].source.url' | ./cloner.sh clone
```

## Settings

```
cloner.sh 
    clone [[-d ./vendor-bak]] [[-p https]] [[-n]] [[file]]
        cloning repos from input list
        [[file]] 
            file name, witch cosist of repos uri every line
            if not present - stdin will be used
     
    fetch [[-d ./vendor-bak]] 
        find all repos in dir and fetch it    
    
    Params:
        -d|--dir 
            base directory for stroring. Default: ./vendor-bak
        -p|--protocol
            will change protocol name. Default: https
            https|http - will change git to http.
            git - will chage http to git
            unchange - stay same
        -n|--no-fetch
            no fetching, if repo already exist
   
```
