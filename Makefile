MAKEFLAGS 				+= --warn-undefined-variables
SHELL 					:= bash
.DEFAULT_GOAL			:= help
URIBASE					:=	http://purl.obolibrary.org/obo
TMP_DATA				:=	data/tmp
ROOT_DIR				:=	$(shell pwd)
PHENOTYPE_DIR			:= $(ROOT_DIR)/data/phenotype
RUNNERS_DIR				:= $(ROOT_DIR)/runners
NAME					:= $(shell python -c 'import tomli; print(tomli.load(open("pyproject.toml", "rb"))["tool"]["poetry"]["name"])')
VERSION					:= $(shell python -c 'import tomli; print(tomli.load(open("pyproject.toml", "rb"))["tool"]["poetry"]["version"])')
SEMSIM_BASE_URL			:= https://storage.googleapis.com/data-public-monarchinitiative/semantic-similarity/latest
EXOMISER_VERSIONS		:=	13.2.1 13.3.0


help: info
	@echo ""
	@echo "help"
	@echo "make setup -- this runs the download and extraction of genomic, phenotypic and runners data"
	@echo "make pheval -- this runs the entire pipeline including setup, corpus preparation and pheval run"
	@echo "make help -- show this help"
	@echo ""

info:
	@echo "Project: $(NAME)"
	@echo "Version: $(VERSION)"

.PHONY: prepare-inputs




$(TMP_DATA)/semsim/phenio-monarch-hp-hp.0.4.semsimian.sql: $(TMP_DATA)/semsim/phenio-monarch-hp-hp.0.4.semsimian.tsv
	pheval-utils semsim-to-exomisersql --input-file $< --subject-prefix hp --object-prefix hp -o $@


$(TMP_DATA)/semsim/phenio-monarch-hp-mp.0.4.semsimian.sql: $(TMP_DATA)/semsim/phenio-monarch-hp-mp.0.4.semsimian.tsv
	pheval-utils semsim-to-exomisersql --input-file $< --subject-prefix hp --object-prefix mp -o $@


$(TMP_DATA)/semsim/phenio-monarch-hp-zp.0.4.semsimian.sql: $(TMP_DATA)/semsim/phenio-monarch-hp-zp.0.4.semsimian.tsv
	pheval-utils semsim-to-exomisersql --input-file $< --subject-prefix hp --object-prefix zp -o $@

prepare-inputs: configurations/default/config.yaml



configurations/default/config.yaml:
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)/

	cp -rf $(PHENOTYPE_DIR)/2309_phenotype $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype
	cp $(RUNNERS_DIR)/configurations/exomiser-13.3.0-2309_phenotype.config.yaml $(ROOT_DIR)/$(shell dirname $@)/config.yaml

	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg19  || ln -s $(PHENOTYPE_DIR)/2309_hg19 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg38 || ln -s $(PHENOTYPE_DIR)/2309_hg38 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype || ln -s $(RUNNERS_DIR)/exomiser-13.3.0/* $(ROOT_DIR)/$(shell dirname $@)/




prepare-inputs: configurations/phenio-hphp-ingest/config.yaml


SQL_DEPENDENCIES_phenio-hphp-ingest = $(TMP_DATA)/semsim/phenio-monarch-hp-hp.0.4.semsimian.sql 

configurations/phenio-hphp-ingest/config.yaml: $(addprefix $(RUNNERS_DIR)/exomiser-,$(EXOMISER_VERSIONS)) $(SQL_DEPENDENCIES_phenio-hphp-ingest)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)/

	cp -rf $(PHENOTYPE_DIR)/2309_phenotype $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype
	cp $(RUNNERS_DIR)/configurations/exomiser-13.3.0-2309_phenotype.config.yaml $(ROOT_DIR)/$(shell dirname $@)/config.yaml

	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg19  || ln -s $(PHENOTYPE_DIR)/2309_hg19 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg38 || ln -s $(PHENOTYPE_DIR)/2309_hg38 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype || ln -s $(RUNNERS_DIR)/exomiser-13.3.0/* $(ROOT_DIR)/$(shell dirname $@)/
	java -Xms128m -Xmx8192m -Dh2.bindAddress=127.0.0.1 -cp $(shell find $< -type f -name "h2*.jar") org.h2.tools.RunScript -url jdbc:h2:file:$(ROOT_DIR)/$(shell dirname $@)/2309_phenotype/2309_phenotype -script $(TMP_DATA)/semsim/phenio-monarch-hp-hp.0.4.semsimian.sql -user sa
 

.PHONY: semsim-ingest
semsim-ingest: configurations/phenio-hphp-ingest/config.yaml




prepare-inputs: configurations/phenio-hpmp-ingest/config.yaml


SQL_DEPENDENCIES_phenio-hpmp-ingest = $(TMP_DATA)/semsim/phenio-monarch-hp-mp.0.4.semsimian.sql 

configurations/phenio-hpmp-ingest/config.yaml: $(addprefix $(RUNNERS_DIR)/exomiser-,$(EXOMISER_VERSIONS)) $(SQL_DEPENDENCIES_phenio-hpmp-ingest)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)/

	cp -rf $(PHENOTYPE_DIR)/2309_phenotype $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype
	cp $(RUNNERS_DIR)/configurations/exomiser-13.3.0-2309_phenotype.config.yaml $(ROOT_DIR)/$(shell dirname $@)/config.yaml

	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg19  || ln -s $(PHENOTYPE_DIR)/2309_hg19 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg38 || ln -s $(PHENOTYPE_DIR)/2309_hg38 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype || ln -s $(RUNNERS_DIR)/exomiser-13.3.0/* $(ROOT_DIR)/$(shell dirname $@)/
	java -Xms128m -Xmx8192m -Dh2.bindAddress=127.0.0.1 -cp $(shell find $< -type f -name "h2*.jar") org.h2.tools.RunScript -url jdbc:h2:file:$(ROOT_DIR)/$(shell dirname $@)/2309_phenotype/2309_phenotype -script $(TMP_DATA)/semsim/phenio-monarch-hp-mp.0.4.semsimian.sql -user sa
 

.PHONY: semsim-ingest
semsim-ingest: configurations/phenio-hpmp-ingest/config.yaml




prepare-inputs: configurations/phenio-hpzp-ingest/config.yaml


SQL_DEPENDENCIES_phenio-hpzp-ingest = $(TMP_DATA)/semsim/phenio-monarch-hp-zp.0.4.semsimian.sql 

configurations/phenio-hpzp-ingest/config.yaml: $(addprefix $(RUNNERS_DIR)/exomiser-,$(EXOMISER_VERSIONS)) $(SQL_DEPENDENCIES_phenio-hpzp-ingest)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)/

	cp -rf $(PHENOTYPE_DIR)/2309_phenotype $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype
	cp $(RUNNERS_DIR)/configurations/exomiser-13.3.0-2309_phenotype.config.yaml $(ROOT_DIR)/$(shell dirname $@)/config.yaml

	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg19  || ln -s $(PHENOTYPE_DIR)/2309_hg19 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg38 || ln -s $(PHENOTYPE_DIR)/2309_hg38 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype || ln -s $(RUNNERS_DIR)/exomiser-13.3.0/* $(ROOT_DIR)/$(shell dirname $@)/
	java -Xms128m -Xmx8192m -Dh2.bindAddress=127.0.0.1 -cp $(shell find $< -type f -name "h2*.jar") org.h2.tools.RunScript -url jdbc:h2:file:$(ROOT_DIR)/$(shell dirname $@)/2309_phenotype/2309_phenotype -script $(TMP_DATA)/semsim/phenio-monarch-hp-zp.0.4.semsimian.sql -user sa
 

.PHONY: semsim-ingest
semsim-ingest: configurations/phenio-hpzp-ingest/config.yaml




prepare-inputs: configurations/phenio-allingest/config.yaml


SQL_DEPENDENCIES_phenio-allingest = $(TMP_DATA)/semsim/phenio-monarch-hp-hp.0.4.semsimian.sql  $(TMP_DATA)/semsim/phenio-monarch-hp-mp.0.4.semsimian.sql  $(TMP_DATA)/semsim/phenio-monarch-hp-zp.0.4.semsimian.sql 

configurations/phenio-allingest/config.yaml: $(addprefix $(RUNNERS_DIR)/exomiser-,$(EXOMISER_VERSIONS)) $(SQL_DEPENDENCIES_phenio-allingest)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)/

	cp -rf $(PHENOTYPE_DIR)/2309_phenotype $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype
	cp $(RUNNERS_DIR)/configurations/exomiser-13.3.0-2309_phenotype.config.yaml $(ROOT_DIR)/$(shell dirname $@)/config.yaml

	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg19  || ln -s $(PHENOTYPE_DIR)/2309_hg19 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_hg38 || ln -s $(PHENOTYPE_DIR)/2309_hg38 $(ROOT_DIR)/$(shell dirname $@)/
	test -L $(ROOT_DIR)/$(shell dirname $@)/2309_phenotype || ln -s $(RUNNERS_DIR)/exomiser-13.3.0/* $(ROOT_DIR)/$(shell dirname $@)/
	java -Xms128m -Xmx8192m -Dh2.bindAddress=127.0.0.1 -cp $(shell find $< -type f -name "h2*.jar") org.h2.tools.RunScript -url jdbc:h2:file:$(ROOT_DIR)/$(shell dirname $@)/2309_phenotype/2309_phenotype -script $(TMP_DATA)/semsim/phenio-monarch-hp-hp.0.4.semsimian.sql -user sa
 
	java -Xms128m -Xmx8192m -Dh2.bindAddress=127.0.0.1 -cp $(shell find $< -type f -name "h2*.jar") org.h2.tools.RunScript -url jdbc:h2:file:$(ROOT_DIR)/$(shell dirname $@)/2309_phenotype/2309_phenotype -script $(TMP_DATA)/semsim/phenio-monarch-hp-mp.0.4.semsimian.sql -user sa
 
	java -Xms128m -Xmx8192m -Dh2.bindAddress=127.0.0.1 -cp $(shell find $< -type f -name "h2*.jar") org.h2.tools.RunScript -url jdbc:h2:file:$(ROOT_DIR)/$(shell dirname $@)/2309_phenotype/2309_phenotype -script $(TMP_DATA)/semsim/phenio-monarch-hp-zp.0.4.semsimian.sql -user sa
 

.PHONY: semsim-ingest
semsim-ingest: configurations/phenio-allingest/config.yaml




.PHONY: prepare-corpora


$(TMP_DATA)/semsim/%.tsv:
	mkdir -p $(TMP_DATA)/semsim/
	wget $(SEMSIM_BASE_URL)/$*.tsv -O $@


results/run_data.txt:
	touch $@

results/gene_rank_stats.svg: results/run_data.txt
	pheval-utils benchmark-comparison -r $< -o $(ROOT_DIR)/$(shell dirname $@)/results --gene-analysis -y bar_cumulative
	mv $(ROOT_DIR)/gene_rank_stats.svg $@

.PHONY: pheval-report
pheval-report: results/gene_rank_stats.svg


results/default/results.yml: configurations/default/config.yaml corpora/lirical/default/corpus.yml


	rm -rf $(ROOT_DIR)/$(shell dirname $@)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)
	pheval run \
	 --input-dir $(ROOT_DIR)/configurations/default \
	 --testdata-dir $(ROOT_DIR)/corpora/lirical/default \
	 --runner exomiserphevalrunner \
	 --tmp-dir data/tmp/ \
	 --version 13.3.0 \
	 --output-dir $(ROOT_DIR)/$(shell dirname $@)

	touch $@
	echo -e "$(ROOT_DIR)/corpora/lirical/default/phenopackets\t$(ROOT_DIR)/$(shell dirname $@)" >> results/run_data.txt

.PHONY: pheval-run
pheval-run: results/default/results.yml

results/phenio-hphp-ingest/results.yml: configurations/phenio-hphp-ingest/config.yaml corpora/lirical/default/corpus.yml


	rm -rf $(ROOT_DIR)/$(shell dirname $@)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)
	pheval run \
	 --input-dir $(ROOT_DIR)/configurations/phenio-hphp-ingest \
	 --testdata-dir $(ROOT_DIR)/corpora/lirical/default \
	 --runner exomiserphevalrunner \
	 --tmp-dir data/tmp/ \
	 --version 13.3.0 \
	 --output-dir $(ROOT_DIR)/$(shell dirname $@)

	touch $@
	echo -e "$(ROOT_DIR)/corpora/lirical/default/phenopackets\t$(ROOT_DIR)/$(shell dirname $@)" >> results/run_data.txt

.PHONY: pheval-run
pheval-run: results/phenio-hphp-ingest/results.yml

results/phenio-hpmp-ingest/results.yml: configurations/phenio-hpmp-ingest/config.yaml corpora/lirical/default/corpus.yml


	rm -rf $(ROOT_DIR)/$(shell dirname $@)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)
	pheval run \
	 --input-dir $(ROOT_DIR)/configurations/phenio-hpmp-ingest \
	 --testdata-dir $(ROOT_DIR)/corpora/lirical/default \
	 --runner exomiserphevalrunner \
	 --tmp-dir data/tmp/ \
	 --version 13.3.0 \
	 --output-dir $(ROOT_DIR)/$(shell dirname $@)

	touch $@
	echo -e "$(ROOT_DIR)/corpora/lirical/default/phenopackets\t$(ROOT_DIR)/$(shell dirname $@)" >> results/run_data.txt

.PHONY: pheval-run
pheval-run: results/phenio-hpmp-ingest/results.yml

results/phenio-hpzp-ingest/results.yml: configurations/phenio-hpzp-ingest/config.yaml corpora/lirical/default/corpus.yml


	rm -rf $(ROOT_DIR)/$(shell dirname $@)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)
	pheval run \
	 --input-dir $(ROOT_DIR)/configurations/phenio-hpzp-ingest \
	 --testdata-dir $(ROOT_DIR)/corpora/lirical/default \
	 --runner exomiserphevalrunner \
	 --tmp-dir data/tmp/ \
	 --version 13.3.0 \
	 --output-dir $(ROOT_DIR)/$(shell dirname $@)

	touch $@
	echo -e "$(ROOT_DIR)/corpora/lirical/default/phenopackets\t$(ROOT_DIR)/$(shell dirname $@)" >> results/run_data.txt

.PHONY: pheval-run
pheval-run: results/phenio-hpzp-ingest/results.yml

results/phenio-allingest/results.yml: configurations/phenio-allingest/config.yaml corpora/lirical/default/corpus.yml


	rm -rf $(ROOT_DIR)/$(shell dirname $@)
	mkdir -p $(ROOT_DIR)/$(shell dirname $@)
	pheval run \
	 --input-dir $(ROOT_DIR)/configurations/phenio-allingest \
	 --testdata-dir $(ROOT_DIR)/corpora/lirical/default \
	 --runner exomiserphevalrunner \
	 --tmp-dir data/tmp/ \
	 --version 13.3.0 \
	 --output-dir $(ROOT_DIR)/$(shell dirname $@)

	touch $@
	echo -e "$(ROOT_DIR)/corpora/lirical/default/phenopackets\t$(ROOT_DIR)/$(shell dirname $@)" >> results/run_data.txt

.PHONY: pheval-run
pheval-run: results/phenio-allingest/results.yml
corpora/lirical/default/corpus.yml:
	test -d $(ROOT_DIR)/corpora/lirical/default/ || mkdir -p $(ROOT_DIR)/corpora/lirical/default/

	test -L $(ROOT_DIR)/corpora/lirical/default/template_exome_hg19.vcf.gz || ln -s $(ROOT_DIR)/testdata/template_vcf/template_exome_hg19.vcf.gz $(ROOT_DIR)/corpora/lirical/default/template_exome_hg19.vcf.gz
	pheval-utils create-spiked-vcfs \
	 --template-vcf-path $(ROOT_DIR)/corpora/lirical/default/template_exome_hg19.vcf.gz  \
	 --phenopacket-dir=$(ROOT_DIR)/corpora/lirical/default/phenopackets \
	 --output-dir $(ROOT_DIR)/corpora/lirical/default/vcf
	touch $@


.PHONY: download-exomiser
download-exomiser: $(addprefix $(RUNNERS_DIR)/exomiser-,$(EXOMISER_VERSIONS))

$(TMP_DATA)/exomiser-cli-%-distribution.zip:
	mkdir -p $(TMP_DATA)
	wget https://github.com/exomiser/Exomiser/releases/download/$*/exomiser-cli-$*-distribution.zip -O $@

$(RUNNERS_DIR)/exomiser-%: $(TMP_DATA)/exomiser-cli-%-distribution.zip
	mkdir -p $(RUNNERS_DIR)
	unzip $< -d $(RUNNERS_DIR)
	mv $(RUNNERS_DIR)/exomiser-cli-$* $(RUNNERS_DIR)/exomiser-$*
	cp $(RUNNERS_DIR)/configurations/preset-exome-analysis.yml $(RUNNERS_DIR)/exomiser-$*/




.PHONY: pheval
pheval:
	$(MAKE) prepare-inputs
	$(MAKE) prepare-corpora
	$(MAKE) pheval-run
	$(MAKE) pheval-report

include ./resources/custom.Makefile
