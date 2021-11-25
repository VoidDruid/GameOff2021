changecom()dnl
define(`node', `extends Node
class_name $1')dnl
define(`upcase', `translit(`$*', `a-z', `A-Z')')dnl
define(`downcase', `translit(`$*', `A-Z', `a-z')')dnl
define(`typename', `"class_$1"')dnl
define(`capitalize1', `regexp(`$1', `^\(\w\)\(\w*\)', `upcase(`\1')`'downcase(`\2')')')dnl
define(`capitalize', `patsubst(`$1', `\w+', ``'capitalize1(`\0')')')dnl
