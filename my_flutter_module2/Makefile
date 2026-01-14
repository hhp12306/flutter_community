# Makefile for Flutter HarmonyOS project

.PHONY: help build-ohos run-ohos update-profile pub-get

help:
	@echo "可用的命令:"
	@echo "  make pub-get        - 执行 flutter pub get 并自动更新配置（如果存在）"
	@echo "  make build-ohos    - 构建鸿蒙产物并自动更新配置"
	@echo "  make run-ohos       - 运行到鸿蒙设备并自动更新配置"
	@echo "  make update-profile - 仅更新 build-profile.json5 配置"

pub-get:
	@echo "执行 flutter pub get 并检查配置..."
	./scripts/pub_get.sh

build-ohos:
	@./scripts/build_ohos.sh

run-ohos:
	@./scripts/run_ohos.sh

update-profile:
	@echo "更新 build-profile.json5 配置..."
	python3 scripts/update_build_profile.py
