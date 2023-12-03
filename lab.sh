#! /bin/bash

# LAB FUNCTION
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
## Auxiliary Data
    declare -a LAB_options
    LAB_options=(QA doc def ref)
    LAB_options_list="${LAB_options[0]}"
    for i in ${!LAB_options[@]}; do
        if [[ ! "$i" == "0" ]]; then
            LAB_options_list="$LAB_options_list, ${LAB_options[$i]}"
        fi
    done
## Auxiliary Functions
    function LAB_index_QA(){
        LAB_QA=$LAB/QA
        LAB_QA_URL="https://lab.yxm.me/QA"
        mapfile -t LAB_QA_dirs < <(find $LAB_QA -maxdepth 1 -type d ! -name QA)
        echo "---" > $LAB_QA/index.md
        echo "title: /lab/QA" >> $LAB_QA/index.md
        echo "---" >> $LAB_QA/index.md
        echo "" >> $LAB_QA/index.md
        echo "* [all](all) ([pdf](all.pdf)) \" >> $LAB_QA/index.md 
        echo "\" >> $LAB_QA/index.md

        echo "" > $LAB_QA/all.md
        echo "---" > $LAB_QA/all.md
        echo "title: /lab/QA/all" >> $LAB_QA/all.md
        echo "author: DevOps Collab" >> $LAB_QA/all.md
        today=$(date +"%B %d, %Y")
        echo "date: $today" >> $LAB_QA/all.md
        echo "documentclass: book" >> $LAB_QA/all.md
        echo "---" >> $LAB_QA/all.md
        echo "" >> $LAB_QA/all.md

        for dir in ${LAB_QA_dirs[@]}; do
            dirname=${dir#"$LAB/QA/"}
            echo "* [$dirname]($dirname/index)" >> $LAB_QA/index.md
            mapfile -t LAB_QA_files < <(find $dir -type f ! -name index.md)
            declare -A LAB_QA_files_title
            echo "---" > $dir/index.md
            echo "title: /lab/QA/$dirname" >> $dir/index.md
            echo "---" >> $dir/index.md
            echo "" >> $dir/index.md

            for file in ${LAB_QA_files[@]}; do
                relative_path=${file#"$dir/"}
                relative_path=${relative_path%.*}
                name=${file##*/}
                name=${name%.*}
                echo "* [$name]($relative_path)" >> $dir/index.md

                cp -r $file /tmp/$name
                sed -i '/^---$/,/^---$/d' /tmp/$name
                echo "# [$dirname: $name]($LAB_QA_URL/$dirname/files/${name}.html)" >> $LAB_QA/all.md
                cat /tmp/$name >> $LAB_QA/all.md
                echo "" >> $LAB_QA/all.md
            done
        done
        pandoc $LAB_QA/all.md --pdf-engine=pdflatex --include-in-header=$LAB_INSTALL/src/preamble.sty --toc --toc-depth=1 -o $LAB_QA/all.pdf
    }
    function LAB_index_doc(){
        LAB_doc=$LAB/doc
        mapfile -t LAB_doc_files < <(find $LAB_doc -type f ! -name index.md)
        echo "---" > $LAB_doc/index.md
        echo "title: /lab/doc" >> $LAB_doc/index.md
        echo "---" >> $LAB_doc/index.md
        echo "" >> $LAB_doc/index.md
        for file in ${LAB_doc_files[@]}; do
            relative_path=${file#"$LAB_doc/"}
            relative_path=${relative_path%.*}
            name=${file##*/}
            name=${name%.*}
            echo "* [$name]($relative_path)" >> $LAB_doc/index.md
        done
    }
    function LAB_index_def(){
        LAB_def=$LAB/def
        mapfile -t LAB_def_files < <(find $LAB_def -type f ! -name index.md)
        echo "---" > $LAB_def/index.md
        echo "title: /lab/def" >> $LAB_def/index.md
        echo "---" >> $LAB_def/index.md
        echo "" >> $LAB_def/index.md
        for file in ${LAB_def_files[@]}; do
            relative_path=${file#"$LAB_def/"}
            relative_path=${relative_path%.*}
            name=${file##*/}
            name=${name%.*}
            echo "* [$name]($relative_path)" >> $LAB_def/index.md
        done
    }
    function LAB_index_ref(){
        LAB_ref=$LAB/ref
        mapfile -t LAB_ref_files < <(find $LAB_ref -type f ! -name index.md)
        echo "---" > $LAB_ref/index.md
        echo "title: /lab/ref" >> $LAB_ref/index.md
        echo "---" >> $LAB_ref/index.md
        echo "" >> $LAB_ref/index.md
        for file in ${LAB_ref_files[@]}; do
            relative_path=${file#"$LAB_ref/"}
            relative_path=${relative_path%.*}
            name=${file##*/}
            name=${name%.*}
            echo "* [$name]($relative_path)" >> $LAB_ref/index.md
        done
    }

    function LAB_cvt_core(){
        name=$(basename $1)
        sed -r 's/(\[.+\])\(([^)]+)\)/\1(\2.html)/g; s/(\[\[.+\]\])/\1(\1.html)/g' < "$1" | pandoc -s $1 -t html5 --template $LAB_TPL | sed -r 's/<li>(.*)\[ \]/<li class="todo done0">\1/g; s/<li>(.*)\[X\]/<li class="todo done4">\1/g; s/https:(.*).html/https:\1/g; s/.md.html/.html/g;' > "$name.html"
    }
    function LAB_cvt_toc(){
        name=$(basename $1)
        sed -r 's/(\[.+\])\(([^)]+)\)/\1(\2.html)/g; s/(\[\[.+\]\])/\1(\1.html)/g' < "$1" | pandoc -s $1 -t html5 --toc --toc-depth=1 --template $LAB_TPL | sed -r 's/<li>(.*)\[ \]/<li class="todo done0">\1/g; s/<li>(.*)\[X\]/<li class="todo done4">\1/g; s/https:(.*).html/https:\1/g; s/.md.html/.html/g;' > "$name.html"
    }
    function LAB_cvt(){
        if [[ -d "$LAB_INSTALL/html" ]]; then
            rm -r $LAB_INSTALL/html
            mkdir $LAB_INSTALL/html
        else
            mkdir $LAB_INSTALL/html
        fi
        cp -r $LAB/* $LAB_INSTALL/html
        mdfiles=$(find $LAB_INSTALL/html -type f -name "*.md" ! -name "README.md" ! -name "all.md")
        cwd=$PWD
        for f in ${mdfiles[@]}; do
            echo "converting $f..."
            dir=$(dirname $f)
            cd $dir
            LAB_cvt_core $f > /dev/null 2>&1 
        done
        allfiles=$(find $LAB_INSTALL/html -type f -name "all.md")
        for f in ${allfiles[@]}; do
            echo "converting $f..."
            dir=$(dirname $f)
            cd $dir
            LAB_cvt_toc $f > /dev/null 2>&1 
        done
        cd $cwd
        echo "fixing possible errors..."
        find $LAB_INSTALL/html -type f -name "*.md" -delete
        find $LAB_INSTALL/html -name '*.md.html' -execdir bash -c 'mv -i "$1" "${1//.md.html/.html}"' bash {} \;
        echo "Done!"
    }
    function LAB_push_md(){
        rsync -av --progress --delete  --exclude '.git/*' --exclude 'README.md' $LAB/ $LAB_MD/md > /dev/null 2>&1
        cd $LAB_MD
        git add .
        git commit -m "$1"
        git push lab_md $LAB_BRANCH
        echo "Done!"
    }
    function LAB_push_html(){
        if [[ -d "$LAB_INSTALL/html" ]]; then
            rsync -av --progress --delete  --exclude '.git/*' --exclude '.domains' --exclude 'tpl/*' $LAB_INSTALL/html/ $LAB_HTML > /dev/null 2>&1
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
    function LAB_new_QA_core(){
        file="/lab/$LAB/QA/$topic/files/${QA_file}.md"
        touch $file
        echo "---" >> $file
        echo "title: QA/$topic/$QA_file" >> $file
        echo "---" >> $file
        echo "" >> $file 
        echo "The QA file \"$QA_file\" was created in the topic \"$topic\"."
    }
    function LAB_new_QA_file(){
        echo "Enter the name of the QA file you want to create in the topic \"$topic\"."
        mapfile -t LAB_QA_files < <(find $LAB/QA/$topic -type f ! -name index.md)
        if [[ -n "${LAB_QA_files[@]}" ]]; then
            echo "The following is the list of already existing topics."
            for file in ${LAB_QA_files[@]}; do
                LAB_QA_files_name[$file]=$(basename $file)
                echo "* $(basename $file)"
            done
            while :
            do
                read -r -p "> " QA_file
                if [[ "${LAB_QA_files_name[@]}" =~ "$QA_file" ]]; then
                    echo "Please, enter a nonexisting QA file name."
                    continue
                else
                    if [[ -z "$QA_file" ]]; then
                        echo "Aborting..."
                        break
                    elif [[ $QA_file =~ ^[a-z\-]+$ ]]; then
                        LAB_new_QA_core
                        break
                    else
                        echo "Please, enter a QA file name containing only lowercase letters and dashes."
                        continue
                    fi
                fi
            done
        else
            while :
            do
                read -r -p "> " QA_file
                if [[ -z "$QA_file" ]]; then
                    echo "Aborting..."
                    break
                elif [[ $QA_file =~ ^[a-z\-]+$ ]]; then
                    LAB_new_QA_core
                    break
                else
                    echo "Please, enter a QA file name containing only lowercase letters and dashes."
                    continue
                fi
            done
        fi
    }
    function LAB_new_QA(){
        echo "Enter the name of the topic in which you want to create your QA file."
        echo "The following is the list of already existing topics."
        LAB_QA=$LAB/QA
        mapfile -t LAB_QA_dirs < <(find $LAB_QA -maxdepth 1 -type d ! -name QA)
        declare -A LAB_QA_dirs_name
        for dir in ${LAB_QA_dirs[@]}; do
            LAB_QA_dirs_name[$dir]=${dir#"$LAB/QA/"}
            echo "* ${dir#"$LAB/QA/"}"
        done
        read -r -p "> " topic
        if [[ -z "$topic" ]]; then
            echo "Aborting..."
        elif [[ "${LAB_QA_dirs_name[@]}" =~ "$topic" ]]; then
            LAB_new_QA_file
        else
            echo "Are you sure you want to create a new topic \"$topic\"? (yes/no)"
            while :
            do
                read -r -p "> " yn
                if [[ "$yn" == "y" ]] || [[ "$yn" == "yes" ]]; then
                    mkdir $LAB_QA/$topic
                    mkdir $LAB_QA/$topic/files
                    touch $LAB_QA/$topic/index.md
                    LAB_new_QA_file
                    break
                elif [[ "$yn" == "n" ]] || [[ "$yn" == "no" ]]; then
                    echo "Aborting..."
                    break
                else
                    echo "Please, write y/yes or n/no."
                fi
            done
        fi
    }
    function LAB_new_doc(){
        echo ""
    }
    function LAB_new_def(){
        echo ""
    }
    function LAB_new_ref(){
        echo ""
    }

## Lab Function Properly
    if  [[ -z "$1" ]]; then
        if [[ -n "$LAB_EDITOR" ]]; then
            eval "$LAB_EDITOR $LAB"
        else
            cat $LAB_INSTALL/src/help.txt
        fi
    elif [[ "$1" == "--config" ]] && [[ -z "$2" ]]; then
          if [[ -f "$LAB_INSTALL/src/config.sh" ]] &&
             [[ -s "$LAB_INSTALL/src/config.sh" ]]; then
            sh $LAB_INSTALL/src/config.sh
        else
            echo "error: None configuration mode defined for the \"lab()\" function."
        fi
    elif ([[ "$1" == "-h" ]] || 
          [[ "$1" == "--help" ]]) &&
          [[ -z "$2" ]]; then
          cat $LAB_INSTALL/src/help.txt
    elif [[ "$1" == "-u" ]] || [[ "$1" == "--uninstall" ]]; then
        cd $LAB_INSTALL/install
        sh uninstall
        cd - > /dev/null
    elif [[ "$1" == "--info" ]]; then
        cat $LAB_INSTALL/src/info.txt
    elif [[ "$1" == "-n" ]] || [[ "$1" == "--new" ]]; then
        if [[ -n "$2" ]]; then
            if [[ "$2" == "QA" ]]; then
                LAB_new_QA
            elif [[ "$2" == "doc" ]]; then
                LAB_new_doc
            elif [[ "$2" == "def" ]]; then
                LAB_new_def
            elif [[ "$2" == "ref" ]]; then
                LAB_new_ref
            else
                echo "error: Invalid argument. The available arguments are:"
                echo "* $LAB_options_list"
            fi
        else
            echo "What do you want to create?"
            echo "Options: $LAB_options_list"
            while :
            do
                read -r -p "> " create
                if [[ "${LAB_options[@]}" =~ "$create" ]]; then
                    eval "LAB_new_${create}"
                    break
                else
                    echo "Please, enter a valid option."
                    continue
                fi
            done
        fi
    elif [[ "$1" == "-i" ]] || [[ "$1" == "--index" ]]; then
            echo "Generating index of QA files..."
            LAB_index_QA
            echo "Generating index of doc files..."
            LAB_index_doc
            echo "Generating index of def files..."
            LAB_index_def
            echo "Generating index of ref files..."
            LAB_index_ref
    elif [[ "$1" == "-c" ]] || 
         [[ "$1" == "-cvt" ]] ||
         [[ "$1" == "--convert" ]]; then
            LAB_cvt
    elif [[ "$1" == "-p" ]] || [[ "$1" == "--push" ]] || [[ "$1" == "push" ]]; then
        if [[ "$2" == "md" ]] || [[ "$2" == "markdown" ]]; then
                if [[ -n "$3" ]]; then
                    LAB_push_md "$3"
                else
                    echo "error: A commit message was not provided."
                fi
            elif [[ "$2" == "html" ]]; then
                if [[ -n "$3" ]]; then
                    LAB_push_html "$3"
                else
                    echo "error: A commit message was not provided."
                fi
            elif [[ -n "$2" ]]; then
                LAB_push_md "$2"
                LAB_push_html "$2"
            else
                echo "error: A commit message was not provided."
            fi

    else 
        echo "error: Option not defined for the \"lab()\" function."
    fi
}
# ALIASES
alias labi="lab -i"
alias labc="lab -c"
alias labn="lab -n"
function labp(){
    if [[ -z "$1" ]]; then
        echo "error: A commit message was not provided."
    else
        lab -i
        lab -c
        lab -p "$1"
    fi
}
   
