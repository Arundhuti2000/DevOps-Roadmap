# CI/CD with GitHub Actions and GitHub Pages

This repository demonstrates a straightforward **Continuous Integration/Continuous Deployment (CI/CD)** pipeline using GitHub Actions to deploy a static website to GitHub Pages.

---

## Project Goal

The primary goal of this project is to learn and understand the concepts of:

* **GitHub Actions**
* **GitHub Pages**
* **Continuous Integration (CI)**
* **Continuous Deployment (CD)**
* Writing **GitHub Actions workflows**

---

## How it Works

### Repository Structure:

* `index.html`: The static website file.
* `.github/workflows/deploy.yml`: The GitHub Actions workflow definition.

### GitHub Actions Workflow (`deploy.yml`):

* **Trigger**: The workflow is triggered on every `push` event to the `main` branch.
* **Conditional Execution**: It is specifically configured to run only if changes are detected in the `index.html` file.
* **Steps**:
    * `actions/checkout@v4`: Checks out the repository content.
    * `actions/upload-pages-artifact@v3`: Uploads the `index.html` file as an artifact for GitHub Pages.
    * `actions/deploy-pages@v4`: Deploys the uploaded artifact to GitHub Pages.

---

## Deployment URL

Once the workflow runs successfully, your website will be accessible at:
`https://<your-username>.github.io/gh-deployment-workflow/`

**Replace `<your-username>` with your actual GitHub username.**

---

## Getting Started

1.  **Create a Repository**: Create a new GitHub repository named `gh-deployment-workflow` (or a name of your choice).
2.  **Add Files**:
    * Create `index.html` with your desired static website content.
    * Create `README.md` with this content.
    * Create the `.github/workflows` directory and then `deploy.yml` inside it with your provided YAML content.
3.  **Enable GitHub Pages**:
    * Go to your repository settings on GitHub.
    * Navigate to "**Pages**" under the "**Code and automation**" section.
    * Under "**Build and deployment**", select "**Deploy from a branch**".
    * Choose `gh-pages` as the branch and `/ (root)` as the folder, then click "**Save**". (The GitHub Action will automatically create and push to the `gh-pages` branch).
4.  **Push Changes**: Push all these files to your `main` branch.

Every subsequent push to the `main` branch that modifies `index.html` will automatically trigger the deployment.

---

## Stretch Goal

Consider enhancing this project by:

* Using a static site generator (e.g., Hugo, Jekyll, Astro) to build a more complex website.
* Adding more files and configuring the workflow to deploy the entire build output.
* Implementing more advanced CI/CD concepts like testing, linting, or multiple environments.