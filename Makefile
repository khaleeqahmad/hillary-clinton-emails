
input/HRC_Email_296.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRC_Email_296.zip -o input/HRC_Email_296.zip
input/HRCEmail_JuneWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_JuneWeb.zip -o input/HRCEmail_JuneWeb.zip
input/HRCEmail_JulyWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_JulyWeb.zip -o input/HRCEmail_JulyWeb.zip
input/Clinton_Email_August_Release.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/Clinton_Email_August_Release.zip -o input/Clinton_Email_August_Release.zip
input/HRCEmail_SeptemberWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_SeptemberWeb.zip -o input/HRCEmail_SeptemberWeb.zip
input/HRCEmail_OctWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_OctWeb.zip -o input/HRCEmail_OctWeb.zip
input/HRCEmail_NovWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_NovWeb.zip -o input/HRCEmail_NovWeb.zip
input/HRCEmail_DecWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_DecWeb.zip -o input/HRCEmail_DecWeb.zip
input/HRCEmail_Jan7thWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_Jan7thWeb.zip -o input/HRCEmail_Jan7thWeb.zip
input/HRCEmail_Jan29thWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_Jan29thWeb.zip -o input/HRCEmail_Jan29thWeb.zip
input/HRCEmail_Feb13thWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_Feb13thWeb.zip -o input/HRCEmail_Feb13thWeb.zip
input/HRCEmail_Feb19thWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_Feb19thWeb.zip -o input/HRCEmail_Feb19thWeb.zip
### Feb 26 not available on WSJ, so manually add to include/
# input/HRCEmail_Feb26thWeb.zip:
# 	mkdir -p input
# 	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_Feb26thWeb.zip -o input/HRCEmail_Feb29thWeb.zip

input/HRCEmail_Feb29thWeb.zip:
	mkdir -p input
	curl http://graphics.wsj.com/hillary-clinton-email-documents/zips/HRCEmail_Feb29thWeb.zip -o input/HRCEmail_Feb29thWeb.zip

INPUT_FILES=input/HRC_Email_296.zip input/HRCEmail_JuneWeb.zip input/HRCEmail_JulyWeb.zip input/Clinton_Email_August_Release.zip input/HRCEmail_SeptemberWeb.zip input/HRCEmail_OctWeb.zip input/HRCEmail_NovWeb.zip input/HRCEmail_DecWeb.zip input/HRCEmail_Jan7thWeb.zip input/HRCEmail_Jan29thWeb.zip input/HRCEmail_Feb13thWeb.zip input/HRCEmail_Feb19thWeb.zip input/HRCEmail_Feb29thWeb.zip #input/HRCEmail_Feb26thWeb.zip
input/metadata.csv:
	mkdir -p input
	python scripts/metadata.py
input: $(INPUT_FILES) input/metadata.csv

working/pdfs/.sentinel: $(INPUT_FILES)
	mkdir -p working/pdfs
	touch working/pdfs/.sentinel
	unzip input/HRC_Email_296.zip -d working/pdfs/may
	unzip input/HRCEmail_JuneWeb.zip -d working/pdfs/june
	unzip input/HRCEmail_JulyWeb.zip -d working/pdfs/july
	unzip input/Clinton_Email_August_Release.zip -d working/pdfs/august
	unzip input/HRCEmail_SeptemberWeb.zip -d working/pdfs/september
	unzip input/HRCEmail_OctWeb.zip -d working/pdfs/october
	unzip input/HRCEmail_NovWeb.zip -d working/pdfs/november
	unzip input/HRCEmail_DecWeb.zip -d working/pdfs/december
	unzip input/HRCEmail_Jan7thWeb.zip -d working/pdfs/january7
	unzip input/HRCEmail_Jan29thWeb.zip -d working/pdfs/january29
	unzip input/HRCEmail_Feb13thWeb.zip -d working/pdfs/february13
	unzip input/HRCEmail_Feb19thWeb.zip -d working/pdfs/february19
	unzip input/HRCEmail_Feb29thWeb.zip -d working/pdfs/february29
	# unzip input/HRCEmail_Feb26thWeb.zip -d working/pdfs/february26
unzip: working/pdfs/.sentinel

working/rawText/.sentinel: working/pdfs/.sentinel
	mkdir -p working/rawText
	touch working/rawText/.sentinel
	python scripts/pdfToRawText.py

working/bodyText/.sentinel: working/rawText/.sentinel
	mkdir -p working/bodyText
	touch working/bodyText/.sentinel
	python scripts/bodyText.py
text: working/bodyText/.sentinel

input/emailsNoId.csv: working/rawText/.sentinel working/bodyText/.sentinel input/metadata.csv
	python scripts/emailsNoId.py

output/Emails.csv: input/emailsNoId.csv
	mkdir -p output
	python scripts/outputCsvs.py
output/Persons.csv: output/Emails.csv
output/Aliases.csv: output/Emails.csv
output/EmailReceivers.csv: output/Emails.csv
csv: output/Emails.csv output/Persons.csv output/Aliases.csv output/EmailReceivers.csv

working/noHeader/Emails.csv: output/Emails.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/Persons.csv: output/Persons.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/Aliases.csv: output/Aliases.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/EmailReceivers.csv: output/EmailReceivers.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

output/database.sqlite: working/noHeader/Emails.csv working/noHeader/Persons.csv working/noHeader/Aliases.csv working/noHeader/EmailReceivers.csv
	-rm output/database.sqlite
	sqlite3 -echo $@ < scripts/sqliteImport.sql

output/hashes.txt: output/database.sqlite
	-rm output/hashes.txt
	echo "Current git commit:" >> output/hashes.txt
	git rev-parse HEAD >> output/hashes.txt
	echo "\nCurrent ouput md5 hashes:" >> output/hashes.txt
	md5 output/*.csv >> output/hashes.txt
	md5 output/*.sqlite >> output/hashes.txt
hashes: output/hashes.txt

sqlite: output/database.sqlite

release: output/database.sqlite output/hashes.txt
	zip -r -X output/release-`date -u +'%Y-%m-%d-%H-%M-%S'` output/*

.PHONY: all requirements clean
requirements:
	pip install -r requirements.txt


all: requirements csv sqlite hashes
	type -P pdftotext

clean:
	rm -rf working
	rm -rf output
