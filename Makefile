default: dep lint

CA_CERT         := $(if $(CA_CERT),$(CA_CERT),'ca.crt')
HELM_REPO_USR   := $(if $(HELM_REPO_USR),$(HELM_REPO_USR),'admin')
HELM_REPO_PSW   := $(if $(HELM_REPO_PSW),$(HELM_REPO_PSW),'12341234')
PRIVATE_REPO    := $(if $(PRIVATE_REPO),$(PRIVATE_REPO),"https://127.0.0.1/chartrepo/core")
BUILD_DATE      := $(if $(BUILD_DATE),$(BUILD_DATE),$(shell date '+%Y-%m-%dT%H:%M:%S'))
BUILD_ENV       := $(if $(BUILD_ENV),$(BUILD_ENV),'dev')

CURRENT_DIR     = .
CHART_PATH      = $(CURRENT_DIR)
VALUE_PATH      = $(CHART_PATH)/env-values/$(BUILD_ENV).yaml

.PHONY: dep
dep:
	@echo "dep:"
	@helm repo update
	@helm dep up $(CHART_PATH)
	@echo ""

.PHONY: lint
lint:
	@echo "lint:"
	@helm lint --with-subcharts --debug $(CHART_PATH) -f $(VALUE_PATH) $(CHART_PATH)
	@echo ""

.PHONY: view
view:
	@echo "view:"
	@helm template --validate -f $(VALUE_PATH) $(CHART_PATH)
	@echo ""

.PHONY: test
test:
	@echo "test:"
	@helm install --dry-run $(TARGET) $(CHART_PATH)
	@echo ""

.PHONY: install
install:
	@echo "install:"
	@helm install $(TARGET) $(CHART_PATH)
	@echo ""

.PHONY: push
push:
	@echo "push:"
	@helm cm-push \
		--ca-file $(CA_CERT) \
		--username $(HELM_REPO_USR) \
		--password $(HELM_REPO_PSW) \
		$(CHART_PATH) $(PRIVATE_REPO)
	@echo ""