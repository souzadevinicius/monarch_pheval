# This includes all the preprocessing not directly related to the PhEval Running

PHENOTYPE_VERSIONS				:=	2302 2309


.PHONY: setup
setup: download-phenotype

.PHONY: download-phenotype
download-phenotype: $(addprefix $(PHENOTYPE_DIR)/,$(addsuffix _hg19.sha256,$(PHENOTYPE_VERSIONS))) $(addprefix $(PHENOTYPE_DIR)/,$(addsuffix _hg38.sha256,$(PHENOTYPE_VERSIONS))) $(addprefix $(PHENOTYPE_DIR)/,$(addsuffix _phenotype.sha256,$(PHENOTYPE_VERSIONS)))

$(PHENOTYPE_DIR)/%.sha256: $(TMP_DATA)/phenogeno_%.zip
	unzip $< -d $(PHENOTYPE_DIR)

$(TMP_DATA)/phenogeno_%.zip:
	mkdir -p $(PHENOTYPE_DIR)
	mkdir -p $(TMP_DATA)
	wget https://data.monarchinitiative.org/exomiser/data/$*.zip -O $@

.PHONY: clean
clean:
	rm -rf $(RUNNERS_DIR) $(TMP_DATA)
