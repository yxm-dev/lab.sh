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
    return
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
    function LAB_clean(){
        echo "Cleaning temporary files..."
        rm -r $LAB_TMP/md
        rm -r $LAB_TMP/html
        mkdir $LAB_TMP/md
        mkdir $LAB_TMP/html
    }
    function LAB_pull(){
        cwd=$PWD
        cd $LAB_MD
        git pull lab_md master 
        cd $cwd
        rsync -av --progress --exclude '.git/*' --exclude 'README.md' $LAB_MD/md $LAB/ > /dev/null 2>&1
    }
    function LAB_index_QA(){
        LAB_QA=$LAB/QA
        LAB_QA_TMP=$LAB_TMP/md/QA 
        mkdir $LAB_QA_TMP
        LAB_QA_URL="https://lab.yxm.me/QA"
        LAB_QA_TMP_URL=""
        LAB_QA_all="$LAB_QA_URL/all.md"
        LAB_QA_all_pdf="$LAB_QA_URL/all.pdf"
        mapfile -t LAB_QA_dirs < <(find $LAB_QA -maxdepth 1 -type d ! -name QA)
        echo "---" > $LAB_QA_TMP/index.md
        echo "title: /lab/QA" >> $LAB_QA_TMP/index.md
        echo "---" >> $LAB_QA_TMP/index.md
        echo "" >> $LAB_QA_TMP/index.md
        echo "* [all]($LAB_QA_all) ([pdf]($LAB_QA_all_pdf)) \" >> $LAB_QA_TMP/index.md 
        echo "\" >> $LAB_QA_TMP/index.md

        echo "" > $LAB_QA_TMP/all.md
        echo "---" > $LAB_QA_TMP/all.md
        echo "title: /lab/QA/all" >> $LAB_QA_TMP/all.md
        echo "author: DevOps Collab" >> $LAB_QA_TMP/all.md
        today=$(date +"%B %d, %Y")
        echo "date: $today" >> $LAB_QA_TMP/all.md
        echo "documentclass: book" >> $LAB_QA_TMP/all.md
        echo "---" >> $LAB_QA_TMP/all.md
        echo "" >> $LAB_QA_TMP/all.md

        for dir in ${LAB_QA_dirs[@]}; do
            dirname=${dir#"$LAB_QA/"}
            dir_tmp=$LAB_QA_TMP/$dirname
            mkdir $dir_tmp
            index_url="$LAB_QA_URL/$dirname/index.html"
            echo "* [$dirname]($index_url)" >> $LAB_QA_TMP/index.md
            mapfile -t LAB_QA_files < <(find $dir -type f ! -name index.md)
            declare -A LAB_QA_files_title
            echo "---" > $dir_tmp/index.md
            echo "title: /lab/QA/$dirname" >> $dir_tmp/index.md
            echo "---" >> $dir_tmp/index.md
            echo "" >> $dir_tmp/index.md

            for file in ${LAB_QA_files[@]}; do 
                name=${file##*/}
                name=${name%.*}
                echo "* [$name]($LAB_QA_URL/$dirname/${name}.html)" >> $dir_tmp/index.md

                cp -r $file /tmp/$name
                sed -i '/^---$/,/^---$/d' /tmp/$name
                echo "# [$dirname: $name]($LAB_QA_URL/$dirname/${name}.html)" >> $LAB_QA_TMP/all.md
                cat /tmp/$name >> $LAB_QA_TMP/all.md
                echo "" >> $LAB_QA_TMP/all.md
            done
        done
        pandoc $LAB_QA_TMP/all.md --pdf-engine=pdflatex --include-in-header=$LAB_INSTALL/src/preamble.sty --toc --toc-depth=1 -o $LAB_QA_TMP/all.pdf
    }
    function LAB_index_doc(){
        LAB_doc=$LAB/doc
        LAB_doc_TMP=$LAB_TMP/md/doc
        mkdir $LAB_doc_TMP
        LAB_doc_URL="https://lab.yxm.me/doc"
        LAB_doc_TMP_URL=""
        LAB_doc_all="$LAB_doc_URL/all.md"
        LAB_doc_all_pdf="$LAB_doc_URL/all.pdf"
        mapfile -t LAB_doc_files < <(find $LAB_doc -type f ! -name index.md)
        echo "---" > $LAB_doc_TMP/index.md
        echo "title: /lab/doc" >> $LAB_doc_TMP/index.md
        echo "---" >> $LAB_doc_TMP/index.md
        echo "" >> $LAB_doc_TMP/index.md
        for file in ${LAB_doc_files[@]}; do 
            name=${file##*/}
            name=${name%.*}
            echo "* [$name]($LAB_doc_URL/${name}.html)" >> $LAB_doc_TMP/index.md
        done
    }
    function LAB_index_def(){
        LAB_def=$LAB/def
        LAB_def_TMP=$LAB_TMP/md/def
        mkdir $LAB_def_TMP
        LAB_def_URL="https://lab.yxm.me/def"
        LAB_def_TMP_URL=""
        LAB_def_all="$LAB_def_URL/all.md"
        LAB_def_all_pdf="$LAB_def_URL/all.pdf"
        mapfile -t LAB_def_files < <(find $LAB_def -type f ! -name index.md)
        echo "---" > $LAB_def_TMP/index.md
        echo "title: /lab/def" >> $LAB_def_TMP/index.md
        echo "---" >> $LAB_def_TMP/index.md
        echo "" >> $LAB_def_TMP/index.md
        for file in ${LAB_def_files[@]}; do 
            name=${file##*/}
            name=${name%.*}
            echo "* [$name]($LAB_def_URL/${name}.html)" >> $LAB_def_TMP/index.md
        done
 
    }
    function LAB_index_ref(){
        LAB_ref=$LAB/ref
        LAB_ref_TMP=$LAB_TMP/md/ref
        mkdir $LAB_ref_TMP
        LAB_ref_URL="https://lab.yxm.me/ref"
        LAB_ref_TMP_URL=""
        LAB_ref_all="$LAB_ref_URL/all.md"
        LAB_ref_all_pdf="$LAB_ref_URL/all.pdf"
        mapfile -t LAB_ref_files < <(find $LAB_ref -type f ! -name index.md)
        echo "---" > $LAB_ref_TMP/index.md
        echo "title: /lab/ref" >> $LAB_ref_TMP/index.md
        echo "---" >> $LAB_ref_TMP/index.md
        echo "" >> $LAB_ref_TMP/index.md
        for file in ${LAB_ref_files[@]}; do 
            name=${file##*/}
            name=${name%.*}
            echo "* [$name]($LAB_ref_URL/${name}.html)" >> $LAB_ref_TMP/index.md
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
        cd $cwd
        echo "fixing possible errors..."
        find $LAB_INSTALL/html -type f -name "*.md" -delete
        find $LAB_INSTALL/html -name '*.md.html' -execdir bash -c 'mv -i "$1" "${1//.md.html/.html}"' bash {} \;
        echo "Done!"
    }
    function LAB_cvt_index(){
        cp -r $LAB_TMP/md/* $LAB_TMP/html
        mdfiles=$(find $LAB_TMP/html -type f -name "*.md" ! -name "README.md" ! -name "all.md")
        cwd=$PWD
        for f in ${mdfiles[@]}; do
            echo "converting $f..."
            dir=$(dirname $f)
            cd $dir
            LAB_cvt_core $f > /dev/null 2>&1 
        done
        allfiles=$(find $LAB_TMP/html -type f -name "all.md")
        for f in ${allfiles[@]}; do
            echo "converting $f..."
            dir=$(dirname $f)
            cd $dir
            LAB_cvt_toc $f > /dev/null 2>&1 
        done
        cd $cwd
        echo "fixing possible errors..."
        find $LAB_TMP/html -type f -name "*.md" -delete
        find $LAB_TMP/html -name '*.md.html' -execdir bash -c 'mv -i "$1" "${1//.md.html/.html}"' bash {} \;
        echo "Done!"
    }
    function LAB_push_md(){
        rsync -av --progress --delete  --exclude '.git/*' --exclude 'README.md' $LAB/ $LAB_MD/md > /dev/null 2>&1
        cwd=$PWD
        cd $LAB_MD
        echo "pushing markdown files..."
        git add . > /dev/null
        git commit -m "$1" > /dev/null
        git push lab_md $LAB_BRANCH > /dev/null
        echo "Done!"
        cd $cwd
    }
    function LAB_push_html(){
        if [[ -d "$LAB_INSTALL/html" ]]; then
            rsync -av --progress --delete  --exclude '.git/*' --exclude '.domains' --exclude 'tpl/*' $LAB_INSTALL/html/ $LAB_HTML > /dev/null 2>&1
            rm -r $LAB_INSTALL/html
            cwd=$PWD
            cd $LAB_HTML
            echo "pushing html files..."
            git add . > /dev/null
            git commit -m "$1" > /dev/null
            git pull lab_html master > /dev/null
            git push lab_html $LAB_BRANCH > /dev/null
            echo "Done!"
            cd $cwd
        else
            echo "error: The .md files were not converted."
            echo "Convert them first with \"lab -c\"."
        fi
    } 
    function LAB_push_index(){
        echo "pushing index files..."
        cp -r $LAB_TMP/html/* $LAB_HTML
        cwd=$PWD
        cd $LAB_HTML
        git add . > /dev/null
        git commit -m "updating indexes..." > /dev/null
        git push lab_html $LAB_BRANCH > /dev/null
        cd $cwd

        cp -r $LAB_TMP/md/* $LAB_MD/md
        cwd=$PWD
        cd $LAB_MD
        git add . > /dev/null
        git commit -m "updating indexes..." > /dev/null
        git push lab_md $LAB_BRANCH > /dev/null
        cd $cwd
    }

    function LAB_new_QA_core(){
        file="$LAB/QA/$topic/files/${QA_file}.md"
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
            LAB_pull
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
    elif [[ "$1" == "-cl" ]] || [[ "$1" == "--clean" ]]; then
            LAB_clean
    elif [[ "$1" == "-i" ]] || [[ "$1" == "--index" ]]; then
        LAB_clean
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
            LAB_cvt_index
    elif [[ "$1" == "-ps" ]] || [[ "$1" == "--push" ]] || [[ "$1" == "push" ]]; then
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
        elif [[ "$2" == "index" ]]; then
            if [[ -n "$3" ]]; then
                LAB_push_index "$3"
            else
                echo "error: A commit message was not provided."
            fi
        elif [[ -n "$2" ]]; then
            LAB_push_md "$2"
            LAB_push_html "$2"
            LAB_push_index "$2"
        else
            echo "error: A commit message was not provided."
        fi
    elif [[ "$1" == "-pl" ]] || [[ "$1" == "--pull" ]] || [[ "$1" == "pull" ]]; then
        LAB_pull
    else 
        echo "error: Option not defined for the \"lab()\" function."
    fi
}

# ALIASES
alias labi="lab -i"
alias labc="lab -c"
alias labcl="lab -i"
alias labn="lab -n"
function labp(){
    if [[ -z "$1" ]]; then
        echo "error: A commit message was not provided."
    else
        lab -i
        lab -c
        lab -ps "$1"
    fi
}
   
