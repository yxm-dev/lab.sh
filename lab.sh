#! /bin/bash
# MAIN FUNCTION
function lab(){
## Includes
source ${BASH_SOURCE%/*}/pkgfile
source ${BASH_SOURCE%/*}/.env
## Checks
if ! grep -q "LAB=" ${BASH_SOURCE%/*}/.env && 
   ! grep -q "LAB_BRANCH=" ${BASH_SOURCE%/*}/.env &&
   ! grep -q "LAB_NAME=" ${BASH_SOURCE%/*}/.env; then
    echo "error: Your instance of lab was not configured yet."
    echo "Configure it with \"lab --config\"."
fi
## Auxiliary Functions
    function LAB_index_QA(){
        LAB_QA=$LAB/QA
        mapfile -t LAB_QA_dirs < <(find $LAB_QA -maxdepth 1 -type d ! -name QA)
        echo "# /lab/QA" > $LAB_QA/index.md
        echo "" >> $LAB_QA/index.md
        for dir in ${LAB_QA_dirs[@]}; do
            name=${dir#"$LAB/md/QA/"}
            echo "* [$name]($name/index)" >> $LAB_QA/index.md
            mapfile -t LAB_QA_files < <(find $dir -type f ! -name index.md)
            declare -A LAB_QA_files_title
            echo "# /lab/QA/$name" > $dir/index.md
            echo "" >> $dir/index.md
            for file in ${LAB_QA_files[@]}; do
                relative_path=${file#"$dir/"}
                relative_path=${relative_path%.*}
                name=${file##*/}
                name=${name%.*}
                echo "* [$name]($relative_path)" >> $dir/index.md
            done
        done
    }
    function LAB_cvt_core(){
        name=$(basename $1)
        sed -r 's/(\[.+\])\(([^)]+)\)/\1(\2.html)/g; s/(\[\[.+\]\])/\1(\1.html)/g' < "$1" | pandoc -s $1 -t html5 --template $LAB_TPL | sed -r 's/<li>(.*)\[ \]/<li class="todo done0">\1/g; s/<li>(.*)\[X\]/<li class="todo done4">\1/g; s/https:(.*).html/https:\1/g; s/.md.html/.html/g;' > "$name.html"
    }
    function LAB_cvt(){
        if [[ -d "$LAB_INSTALL/html" ]]; then
            rm -r $LAB_INSTALL/html
            mkdir $LAB_INSTALL/html
        else
            mkdir $LAB_INSTALL/html
        fi
        cp -r $LAB/* $LAB_INSTALL/html
        htmlfiles=$(find $LAB_INSTALL/html -type f -name "*.md" ! -name "README.md")
        cwd=$PWD
        for f in ${htmlfiles[@]}; do
            echo "converting $f..."
            dir=$(dirname $f)
            cd $dir
            LAB_cvt_core $f > /dev/null 2>&1 
        done
        cd $cwd
        echo "fixing possible errors..."
        find $LAB_INSTALL/html -type f -name "*.md" -delete
        find $LAB_INSTALL/html -name '*.md.html' -execdir bash -c 'mv -i "$1" "${1//.md.html/.html}"' bash {} \;
        echo "Done!"
    }
    function LAB_push_md(){
        rsync -av --progress --delete  --exclude '.git/*' --exclude 'README.md' $LAB/ $LAB_MD/md
        cd $LAB_MD
        git add .
        git commit -m "$1"
        git push lab_md $LAB_BRANCH
        echo "Done!"
    }
    function LAB_push_html(){
        if [[ -d "$LAB_INSTALL/html" ]]; then
            rsync -av --progress --delete  --exclude '.git/*' --exclude '.domains' --exclude 'tpl/*' $LAB_INSTALL/html/ $LAB_HTML
            rm -r $LAB_INSTALL/html
            cd $LAB_HTML
            git add .
            git commit -m "$1"
            git push lab_html $LAB_BRANCH
            echo "Done!"
        else
            echo "error: The .md files were not converted."
            echo "Convert them first with \"lab -c\"."
        fi
    }
## without options enter in the interactive mode or print help
    if  [[ -z "$1" ]]; then
        if [[ -n "$LAB_EDITOR" ]]; then
            eval "$LAB_EDITOR $LAB"
        else
            cat $LAB_INSTALL/src/help.txt
        fi
## "--config" option to enter in the configuration mode
    elif [[ "$1" == "--config" ]] && [[ -z "$2" ]]; then
          if [[ -f "$LAB_INSTALL/src/config.sh" ]] &&
             [[ -s "$LAB_INSTALL/src/config.sh" ]]; then
            sh $LAB_INSTALL/src/config.sh
        else
            echo "error: None configuration mode defined for the \"lab()\" function."
        fi
## "-h" and "--help" options to print help
    elif ([[ "$1" == "-h" ]] || 
          [[ "$1" == "--help" ]]) &&
          [[ -z "$2" ]]; then
          cat $LAB_INSTALL/src/help.txt
## "-u" and "--uninstall" options to execute the uninstall script
    elif [[ "$1" == "-u" ]] || [[ "$1" == "--uninstall" ]]; then
        cd $LAB_INSTALL/install
        sh uninstall
        cd - > /dev/null
    elif [[ "$1" == "-i" ]]; then
            LAB_index_QA
    elif [[ "$1" == "-c" ]] || 
         [[ "$1" == "-cvt" ]] ||
         [[ "$1" == "--convert" ]]; then
            LAB_cvt
    elif [[ "$1" == "-p" ]]; then
        if [[ "$2" == "md" ]]; then
                if [[ -n "$3" ]]; then
                    LAB_push_md "$3"
                else
                    echo "error: a commit message was not provided."
                fi
            elif [[ "$2" == "html" ]]; then
                if [[ -n "$3" ]]; then
                    LAB_push_html "$3"
                else
                    echo "error: a commit message was not provided."
                fi
            elif [[ -n "$2" ]]; then
                LAB_push_md "$2"
                LAB_push_html "$2"
            else
                echo "error: a commit message was not provided."
            fi

    else 
        echo "error: Option not defined for the \"lab()\" function."
    fi
}
# ALIASES

alias labi="lab -i"
alias labc="lab -c"
function labp(){
    lab -p "$1"
}
   
