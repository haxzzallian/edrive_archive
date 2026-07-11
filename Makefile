.PHONY: run-dev run-staging run-prod build-apk-prod build-bundle-prod clean

run-dev:
	flutter run --flavor dev -t lib/main_dev.dart

run-staging:
	flutter run --flavor staging -t lib/main_staging.dart

run-prod:
	flutter run --flavor prod -t lib/main_prod.dart

build-apk-prod:
	flutter build apk --release --flavor prod -t lib/main_prod.dart

build-bundle-prod:
	flutter build appbundle --release --flavor prod -t lib/main_prod.dart

clean:
	flutter clean && flutter pub get
