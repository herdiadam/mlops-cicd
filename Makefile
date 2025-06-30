# =========================
# MLOps - Makefile
# =========================

# Install dependencies
install:
	pip install --upgrade pip && \
	pip install -r requirements.txt

# Format python files using black
format:
	black *.py

# Train the model and save outputs
train:
	python train.py

# Evaluate model & generate CML report
eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md

	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md

	cml comment create report.md

# Commit model and results to update branch
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Update with new results"
	git push --force origin HEAD:update

# Login ke Hugging Face CLI menggunakan token dari variabel $(HF)
hf-login:
	git pull origin update
	git switch update
	pip install -U "huggingface_hub[cli]"
	huggingface-cli login --token $(HF) --add-to-git-credential

# Upload App, Model, dan Results ke Hugging Face Space kamu
push-hub:
	huggingface-cli upload herdiadam/MLOps-Drug ./App --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload herdiadam/MLOps-Drug ./Model /Model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload herdiadam/MLOps-Drug ./Results /Metrics --repo-type=space --commit-message="Sync Results"

# Jalankan deployment
deploy: hf-login push-hub
