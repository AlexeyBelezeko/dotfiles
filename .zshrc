# fixing and binding keys
autoload zkbd
# [[ ! -d ~/.zkbd ]] && mkdir ~/.zkbd
# [[ ! -f ~/.zkbd/$TERM-$VENDOR-$OSTYPE ]] && zkbd

# source  ~/.zkbd/$TERM-$VENDOR-$OSTYPE
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
[[ -n ${key[Home]}    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n ${key[End]}     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n ${key[Insert]}  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n ${key[Delete]}  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n ${key[Up]}      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n ${key[Down]}    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n ${key[Left]}    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n ${key[Right]}   ]]  && bindkey  "${key[Right]}"   forward-char
[[ -n ${key[Backspace]}   ]]  && bindkey  "${key[Backspace]}"   backward-delete-char

bindkey "^[[5~" up-line-or-history
bindkey "^[[6~" down-line-or-history

# system variables
unlimit
limit stack 8192
limit core 0
limit -s
umask 022

# shell functions
setenv() { typeset -x "${1}${1:+=}${(@)argv[2,$#]}" }  # csh compatibility
freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }

# autoload zsh modules
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile

# complitions
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~''*?.old' '*?.pro'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=$color[cyan]=$color[red]"
zstyle ':completion:*' menu yes select

zstyle ':completion:*:hosts' hosts $hosts
zstyle ':completion:*:(ssh|scp):*' tag-order '! users'

# shell options
autoload -U compinit && compinit
HISTFILE=~/.zhistory
SAVEHIST=5000
setopt  APPEND_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE NO_BEEP AUTO_CD CORRECT_ALL SH_WORD_SPLIT histexpiredupsfirst histfindnodups
setopt histignoredups histnostore histverify histignorespace extended_history  share_history
setopt   notify globdots correct pushdtohome cdablevars autolist
setopt   correctall autocd recexact longlistjobs
setopt   autoresume histignoredups pushdsilent noclobber
setopt   autopushd pushdminus extendedglob rcquotes mailwarning
unsetopt bgnice autoparamslash

setopt  IGNORE_EOF

typeset -U path cdpath fpath manpath

autoload colors && colors

# promts
autoload -Uz promptinit
promptinit
prompt adam2
#PROMPT="%{$fg_bold[grey]%}>> %{$reset_color%}"
#RPROMPT="%{$fg_bold[grey]%}%~/ %{$reset_color%}% %(?,%{$fg[green]%}:%)%{$reset_color%},%{$fg[red]%}:(%{$reset_color%}"
SPROMPT='zsh: Replace '\''%R'\'' by '\''%r'\'' ? [Yes/No/Abort/Edit] '

# headers
precmd() {
     [[ -t 1 ]] || return
    case $TERM in
    *xterm*|rxvt|(dt|k|E|a)term*) print -Pn "\e]0;[%~] %m\a"    ;;
    screen(-bce|.linux)) print -Pn "\ek[%~]\e\" && print -Pn "\e]0;[%~] %m (screen)\a" ;;  #заголовок для скрина
    esac
}
preexec() {
    [[ -t 1 ]] || return
    case $TERM in
    *xterm*|rxvt|(dt|k|E|a)term*) print -Pn "\e]0;<$1> [%~] %m\a" ;;
    screen(-bce|.linux)) print -Pn "\ek<$1> [%~]\e\" && print -Pn "\e]0;<$1> [%~] %m (screen)\a" ;; #заголовок для скрина
    esac
}
typeset -g -A key

# special symbols
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

autoload -U zcalc

# functions
ccd() { cd && ls}
mcd(){ mkdir $1; cd $1 }
rcd(){ local P="`pwd`"; cd .. && rmdir "$P" || cd "$P"; }
name() {
    name=$1
    vared -c -p 'rename to: ' name
    command mv $1 $name
}

extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1        ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1       ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1        ;;
            *.tbz2)      tar xjf $1      ;;
            *.tgz)       tar xzf $1       ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1    ;;
            *)           echo "I do not know how to unpack it '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

pk () {
    if [ $1 ] ; then
        case $1 in
            tbz)    tar cjvf $2.tar.bz2 $2      ;;
            tgz)    tar czvf $2.tar.gz  $2      ;;
            tar)    tar cpvf $2.tar  $2       ;;
            bz2)    bzip $2 ;;
            gz)     gzip -c -9 -n $2 > $2.gz ;;
            zip)    zip -r $2.zip $2   ;;
            7z)     7z a $2.7z $2    ;;
            *)      echo "'$1' cannot be packed via pk()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}


export GREP_COLOR="1;33"
[[ -x $(whence -p most) ]] && export PAGER=$(whence -p most)
export EDITOR='vim'
export VISUAL='vim -f'
export LS_COLORS='no=00;37:fi=00;37:di=01;36:ln=04;36:pi=33:so=01;35:do=01;35:bd=33;01:cd=33;01:or=31;01:su=37:sg=30:tw=30:ow=34:st=37:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.btm=01;31:*.sh=01;31:*.run=01;31:*.tar=33:*.tgz=33:*.arj=33:*.taz=33:*.lzh=33:*.zip=33:*.z=33:*.Z=33:*.gz=33:*.bz2=33:*.deb=33:*.rpm=33:*.jar=33:*.rar=33:*.jpg=32:*.jpeg=32:*.gif=32:*.bmp=32:*.pbm=32:*.pgm=32:*.ppm=32:*.tga=32:*.xbm=32:*.xpm=32:*.tif=32:*.tiff=32:*.png=32:*.mov=34:*.mpg=34:*.mpeg=34:*.avi=34:*.fli=34:*.flv=34:*.3gp=34:*.mp4=34:*.divx=34:*.gl=32:*.dl=32:*.xcf=32:*.xwd=32:*.flac=35:*.mp3=35:*.mpc=35:*.ogg=35:*.wav=35:*.m3u=35:';
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

alias grep='grep --color=auto'
alias h='history'
alias df='df -h'
alias du='du -h'
alias mv='nocorrect mv -i'
alias cp='nocorrect cp -iR'
alias rm='nocorrect rm -i'
alias rmf='nocorrect rm -f'
alias rmrf='nocorrect rm -fR'
alias mkdir='nocorrect mkdir'
alias ls='ls -F -G'
alias vim='vim -v'

# coloring
[[ -f /usr/bin/grc ]] && {
  alias ping="grc --colour=auto ping"
  alias traceroute="grc --colour=auto traceroute"
  alias diff="grc --colour=auto diff"
  alias netstat="grc --colour=auto netstat"
}

alias logc="grc cat"
alias logt="grc tail"
alias logh="grc head"

# load commands for files
alias -s {zip,fb2}=fbless
alias -s txt=$PAGER
alias -s {ogg,mp3,wav,wma}=mplayer
alias -s {php,conf}=$EDITOR

#global aliases
alias -g H="| head"
alias -g S="sudo "
alias -g T="| tail"
alias -g G="| grep"
alias -g L="| less"
alias -g M="| most"
alias -g B="&|"
alias -g HL="--help"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"


# convert aliases
alias -g KU="| iconv -c -f koi8r -t utf8"
alias -g CU="| iconv -c -f cp1251 -t utf8"
alias -g UK="| iconv -c -f utf8 -t koi8r"
alias -g UC="| iconv -c -f utf8 -t cp1251"

# other aliases
alias svim="sudo vim"

# ls and dir tree
alias lls="ls -l | sed -e 's/--x/1/g' -e 's/-w-/2/g' -e 's/-wx/3/g' -e 's/r--/4/g'  -e 's/r-x/5/g' -e 's/rw-/6/g' -e 's/rwx/7/g' -e 's/---/0/g'"
alias dirf='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"'

# grep for processes
alias psgrep='ps aux | grep $(echo $1 | sed "s/^\(.\)/[\1]/g")'

# delete spaces and comments from 
alias delspacecomm="sed '/ *#/d; /^ *$/d' $1"

# create pass
alias mkpass="head -c6 /dev/urandom | xxd -ps"

# for node.js
export NODE_PATH=/usr/local/lib/node_modules
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
export PATH="/usr/local/sbin:$PATH"
