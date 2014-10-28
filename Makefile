RAW_FILE = raw.txt
FEAT_FILE = kytea-0.4.2.feat
PREANNOT_FILE = preannot.txt
EDITOR = vim
KYTEA = ~/kytea/bin/kytea

.PHONY: main prepare validate train edit save clean

main:
	@echo "How to use"
	@echo "    prepare: prepare files and directories for training"
	@echo "    train: execute makemode.sh"
	@echo "    edit: edit the latest work/*.annot file"
	@echo "    save: execute saveannot.sh after checking syntax"

prepare: validate
	if [ ! -e work ]; then mkdir work; fi
	if [ ! -e save ]; then mkdir save; fi
	if [ ! -e data ]; then mkdir data; fi
	if [ ! -e data/${RAW_FILE} ]; then ln -sr src/${RAW_FILE} data/${RAW_FILE}; fi
	if [ ! -e data/${FEAT_FILE} ]; then ln -sr src/${FEAT_FILE} data/${FEAT_FILE}; fi
	if [ \( -e src/${PREANNOT_FILE} \) -a ! \( -e save/000.wann \) ]; then ln -sr src/${PREANNOT_FILE} save/000.wann; fi

validate:
	for file in src/annot/*; do echo -n validate $$file ... && python validate.py $$file && echo " done"; done

train:
	./makemodel.sh
	for file in work/*.mod; do :; done && cp $$file src/save/train.model && chmod 600 src/save/train.model

edit:
	for file in work/*.annot; do :; done && ${EDITOR} $$file

save:
	for file in work/*.annot; do :; done && awk -F": " '{ print $$2 }' $$file | python validate.py
	./saveannot.sh
	for file in save/*.wann; do :; done && cp $$file src/save/annot.txt && chmod 600 src/save/annot.txt

test:
	for file in work/*.mod; do :; done && ${KYTEA} -model $$file

clean:
	#if [ -e save/000.mod ]; then for file in save/*.wann; do :; done && cp $$file src/annot.txt; fi
	#if [ -e work/000.mod ]; then for file in work/*.mod; do :; done && cp $$file src/kytea.mod; fi
	#cp src/{${RAW_FILE},${FEAT_FILE}} work
	rm -rf work save data
