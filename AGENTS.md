# resume
This repo manages my resume in a JSONResume format.

## Structure
- The resume itself is declared at resume.yaml and follows the JSONResume jsonschema as specified in the schema header.
- Sensitive details that I want to inject into my resume are held in the `secrets/` directory. You should never check in a decrypted version of the contents of this directory.
- The project is managed using a nix devshell declared by the flake.nix
- I'm using the `goresume` binary as tooling to render my resume that I can send to recruiters.

## Style Guide
- Always prefer adherance to the JSONResume jsonschema. I will sometimes ask to build off of the schema when it doesn't fully fit my needs.
- I prefer when sentences are presented in the past tense.
- I like it when the first sentence of a highlight or summary is concise and describes the project/responsibility/role at a high level.
- I prefer when each fact within a highligh or summary is separated by a period rather than by a comma.
