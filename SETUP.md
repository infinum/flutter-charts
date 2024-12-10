# Setup instructions

Before you start using this template, complete the following steps:

## Required changes

- [ ] Protect the `main` branch
- [x] Add a short description of the repository
- [x] Add tags for the repository
    - [x] `open-source`,
    - [x] technology tag (`android`, `ios`, `ruby`, `javascript` etc.),
    - [x] other tags that are relevant to the repository
- [x] Create a `.gitignore` file
- [x] Create workflows
- [x] Update the `README.md` file with the missing information
    - [x] Delete the _Setup instructions_ note from the file
    - [x] Add the project name
    - [x] Add the missing information based on the comments in the file
- [ ] Add code owners to the `.github/CODEOWNERS` file
- [x] Define a changelog strategy[^1]
- [ ] Delete the `SETUP.md` file

## Optional changes

The repository files can be changed if the project requires it.

### Project information

If your project needs to provide additional information like backward compatibility, system status or similar, include it to the `README.md` or additional file in a clear and informative format (e.g. compatibility matrix, table, timeline, etc.). Also, if there is a need for additional information for contributors, additional security measures or specific license, update and adjust related files.

### Issue templates

The same applies to issue and pull request templates, where you can adjust information based on the project requirements or required checks in the list (e.g., testing types, performance information, accessibility, etc.).

### Changes checklist

If there is a project-specific need, feel free to update and adjust the following files:

- [ ] Update the `CODE_OF_CONDUCT.md` file
- [ ] Update the `CONTRIBUTING.md` file
- [ ] Update the `SECURITY.md` file
- [ ] Update the `LICENSE` file
- [ ] Update the pull request template
- [ ] Update issue templates

[^1]: Define how changes will be documented; e.g. `CHANGELOG.md` file, Releases section in GitHub, usage of additional tools, etc.