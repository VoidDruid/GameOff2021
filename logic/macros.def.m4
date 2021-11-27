changecom()dnl
define(`node', `extends Node
class_name $1')dnl
define(`upcase', `translit(`$*', `a-z', `A-Z')')dnl
define(`downcase', `translit(`$*', `A-Z', `a-z')')dnl
define(`typename', `"class_$1"')dnl
define(`capitalize1', `regexp(`$1', `^\(\w\)\(\w*\)', `upcase(`\1')`'downcase(`\2')')')dnl
define(`capitalize', `patsubst(`$1', `\w+', ``'capitalize1(`\&')')')dnl
divert(-1)dnl
define(`foreach', `pushdef(`$1', `')_foreach(`$1', `$2', `$3')popdef(`$1')')dnl
define(`_arg1', `$1')dnl
define(`_foreach',
	`ifelse(`$2', `()', ,
		`define(`$1', _arg1$2)$3`'_foreach(`$1', (shift$2), `$3')')')dnl
divert`'dnl`'
define(`concat', `$1$2')dnl
