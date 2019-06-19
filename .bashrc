# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000000
HISTFILESIZE=20000000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# User specific aliases and functions
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
function proml {
  local        BLUE="\[\033[0;34m\]"
  local         RED="\[\033[0;31m\]"
  local   LIGHT_RED="\[\033[1;31m\]"
  local       GREEN="\[\033[0;32m\]"
  local LIGHT_GREEN="\[\033[1;32m\]"
  local       WHITE="\[\033[1;37m\]"
  local  LIGHT_GRAY="\[\033[0;37m\]"
  case $TERM in
    xterm*)
        TITLEBAR='\[\033]0;\u@\h:\w\007\]'

        ;;
    *)
    TITLEBAR=""
    ;;
  esac

# $BLUE[$RED\$(date +%H:%M)$BLUE]\
  PS1="${TITLEBAR}\
    $BLUE[$RED\u@\h:\W$GREEN\$(parse_git_branch)$BLUE]\
    $GREEN\$$WHITE "
  PS2='> '
  PS4='+ '
}
proml


# refer to /usr/local/etc/privoxy/config
function use_proxy {
  export http_proxy='http://127.0.0.1:8118'
  export https_proxy='http://127.0.0.1:8118'
}

function close_proxy {
  unset http_proxy
  unset https_proxy
}

#ALTOOL=`find "/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/"  -iname altool`
function kube {
  kubectl --kubeconfig=$HOME/Dropbox/wansong.kubeconfig -n c-dev "$@"
}

function kubesim {
  kubectl --kubeconfig=$HOME/wansong-production.kubeconfig -n c-test "$@"
}

function kubeprod {
  kubectl --kubeconfig=$HOME/wansong-production.kubeconfig -n c-production "$@"
}


function start_virtual_python_env {
  python_exe=$1
  if [ ! -d "$HOME/.virtualenv" ] ;then
    mkdir "$HOME/.virtualenv"
  fi
  
  if [ ! -d "$HOME/.virtualenv/$python_exe" ] ;then
    virtualenv -p $python_exe "$HOME/.virtualenv/$python_exe"
  fi

  source "$HOME/.virtualenv/$python_exe/bin/activate"
}

function vpy3 {
  start_virtual_python_env python3
}

function kubesel {
  local pat=$1

  local lines=$(kube get po | grep -E "$pat")
  local IFSBack=$IFS
  IFS=$'\n'
  local lines=($lines)
  IFS=$IFSBack

  local pod=
  while [ -z "$pod" ] ; do
    echo "选择匹配的pod："
    select pod in "${lines[@]}" ; do
      if [ -n "$pod" ] ; then
        break
      fi
    done
  done

  local pod_fields=($pod)
  local pod=${pod_fields[0]}

  local cmds=("kube logs -f "'${pod}' "kube exec -it "'${pod}'" sh" "custom")
  local cmd=
  while [ -z "$cmd" ] ; do
    echo "选择命令：1，2执行预置命令，选择3输入自定义命令。"
    select cmd in "${cmds[@]}"; do
      if [ -n "$cmd" ] ; then
        break
      fi
    done
    if [ "$cmd" = "custom" ] ; then
      echo '输入自定义命令，使用${pod}指代刚才选择的pod。'
      read cmd
    fi
    eval "$cmd"
  done
}

# github personal access token
export PAT='02162745503af0c7018a657e141b9e151d98a868'

# 一键打包所有本地重要文档
function packup() {
  # 当前用户的文档
  local user_profile=.bash_profile
  local gitconfig=.gitconfig
  local sshfiles=.ssh
  local local_only_dir=local-only/
  local my_archives=my-archives/
  local kubeconfig=kube.config
  local output_zip=packed.zip

  # 导出一些配置数据
  ls /Applications > "${my_archives}Applications.txt"
  echo -e "ec2-54-169-52-86.ap-southeast-1.compute.amazonaws.com\n" \
    "2160\n" \
    "816086ac\n" \
    > "${my_archives}/shadowsocks.conf"
  zip -r "$output_zip" "$gitconfig" "$sshfiles" "$user_profile" "$local_only_dir" "$my_archives" "$kubeconfig"

  # 全局文档
  cd /
  zip -r ${HOME}/packed-system.zip \
    Library/LaunchDaemons/site.xway.privoxy.plist \
    Library/LaunchDaemons/demo.python.web.plist \
    usr/local/etc/privoxy/config
  cd - >/dev/null 2>&1
}

set -o vi

# 下载gitcompletion脚本
git_completion_bash=.git-completion.bash
if [ ! -f $git_completion_bash ] ; then
  echo "Downloading config from github ..."
  curl -o $git_completion_bash -sL \
    'https://raw.githubusercontent.com/markgandolfo/git-bash-completion/master/git-completion.bash'
fi
test -f $git_completion_bash && source $_

export TERM="xterm-256color"
