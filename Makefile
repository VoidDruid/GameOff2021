### NOT A PROJECT BUILD FILE ###
### Shortcuts for utilities

SCRIPTS_DIR=scripts

help:  ## Показать это сообщение
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

apply_m4:  ## Применить макросы и сгенерировать файлы
	$(SCRIPTS_DIR)/apply_m4.sh

check_ts:  ## Проверить, перевод для каких строк есть в одних языках, но нет в других
	$(SCRIPTS_DIR)/translation_check.sh
