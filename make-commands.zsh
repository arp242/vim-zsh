#!/bin/zsh

(( ! $+argv[1] )) && print >&2 'set the first argument to a zsh source direcrory' && exit 1
src=$1

gen() {
	local file=$1
	local name=$2
	local IFS=$'\n'
	typeset -U all=()

	for opt in $(grep '^findex([A-Za-z_]*)$' $file); do
		all+=(${${(L)opt#findex\(}%\)})
	done
	for opt in $(grep '^zlecmd([A-Za-z_]*)$' $file); do
		all+=(${${(L)opt#zlecmd\(}%\)})
	done
	for opt in $(grep '^alias([A-Za-z_]*)(.*)$' $file); do
		all+=(${${(L)opt#alias\(}%%\)*})
	done
	for opt in $(grep '^module([A-Za-z_]*)(.*)$' $file); do
		all+=(${${(L)opt#module\(}%%\)*})
	done
	for opt in $(grep '^item(tt([A-Za-z_]*)' $file); do
		opt=${${(L)opt#item\(tt\(}%%\)*}
		case $opt in
			(bash|normal|shell|whitespace|default|specified unspecified) ;;
			(*) all+=($opt)
		esac
	done
	for opt in $(grep '^xitem(tt([A-Za-z_]*)' $file); do
		all+=(${${(L)opt#xitem\(tt\(}%%\)*})
	done

	all=(${(o)all})
	lines=($(fold -sw100 <<<${(j: :)all}))
	print -r "syn keyword $name"
	print    "           \\\ ${(j:\n           \\ :)lines}"
}

gen $src/Doc/Zsh/builtins.yo zshBuiltins
gen $src/Doc/Zsh/contrib.yo  zshContrib
