#! /bin/bash

echo "Welcome to the configuration mode of the lab project."

echo "Where do you want to manage your copy of the lab project?"
echo "Enter the full path. Leave in blank to set the working directory."
read -r -p "> " lab_dir
if [[ -z "$lab_dir" ]]; then
    if [[ -d $PWD/lab ]]; then
        echo "error: There already exists a directory named \"lab\" in the working directory."
        return
    elif [[ -f $PWD/lab ]]; then
        echo "error: There already exists a file named \"lab\" in the working directory."
         return
    else
        echo "LAB=$PWD/lab" >> $LAB_INSTALL/.env
        echo "LAB_MD=$LAB_INSTALL/git/lab.md" >> $LAB_INSTALL/.env
        echo "LAB_HTML=$LAB_INSTALL/git/lab" >> $LAB_INSTALL/.env
        echo "LAB_TMP=$LAB_INSTALL/git/lab.tmp" >> $LAB_INSTALL/.env
    fi
else
    echo "$lab_dir" >> $LAB_INSTALL/.env
    echo "LAB_MD=$LAB_INSTALL/git/lab.md" >> $LAB_INSTALL/.env
    echo "LAB_HTML=$LAB_INSTALL/git/lab" >> $LAB_INSTALL/.env
    echo "LAB_TMP=$LAB_INSTALL/git/lab.tmp" >> $LAB_INSTALL/.env
fi

echo "Enter your full name."
echo "This will define your branch and the name to appear in the contributors list".
while :
do
    read -r -p "> " name
    if [[ -z "$name" ]]; then
        echo "Please, enter your full name."
        continue
    else
        echo "LAB_NAME=$name" >> $LAB_INSTALL/.env
        branch=$(echo "$name" | sed 's/ /-/g; s/\(.*\)/\L\1/')
        cd $LAB_INSTALL/git/lab
        if git show-ref --quiet refs/heads/${branch}; then
            n=2
            while :
            do
                if git show-ref --quiet refs/heads/${branch}-${n}; then
                    (( n++ ))
                    continue
                else
                    branch=${branch}-${n}
                    echo "LAB_BRANCH=$branch" >> $LAB_INSTALL/.env
                    break
                fi
            done
        else
            echo "LAB_BRANCH=$branch" >> $LAB_INSTALL/.env
        fi        
    fi
done

echo "Enter a url to your personal page, linkedin, github, etc."
echo "Leave blank to omit this info."
read -r -p "> " url
while :
do
    if [[ -n "$url" ]]; then
        if [[ $url =~ ^https://.*$ ]]; then
            echo "LAB_URL=$url" >> $LAB_INSTALL/.env
            break
        else
            echo "Please, enter a url in the https:// protocol."
            continue
        fi
    else
        break
    fi
done


