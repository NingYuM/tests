# Author: hustcer
# Create: 2022/04/29 18:05:20
# Description:
#   Some helper task for setup-nu
# Ref:
#   1. https://github.com/casey/just
#   2. https://www.nushell.sh/book/

set shell := ['nu', '-c']

# The export setting causes all just variables
# to be exported as environment variables.

set export := true
set dotenv-load := true

# If positional-arguments is true, recipe arguments will be
# passed as positional arguments to commands. For linewise
# recipes, argument $0 will be the name of the recipe.

set positional-arguments := true

# Just commands aliases
alias r := run
# alias b := build

# Use `just --evaluate` to show env vars

# Used to handle the path separator issue
SETUP_NU_PATH := parent_directory(justfile())
NU_DIR := parent_directory(`(which nu).path.0`)
_query_plugin := if os_family() == 'windows' { 'nu_plugin_query.exe' } else { 'nu_plugin_query' }

# To pass arguments to a dependency, put the dependency
# in parentheses along with the arguments, just like:
# default: (sh-cmd "main")

# List available commands by default
default:
  @just --list --list-prefix "··· "

# Run the full test matrix in the repository tracked by the current branch
run:
  @let branch = (git branch --show-current | str trim); \
    let remote = (git config --get $'branch.($branch).remote' | complete); \
    if $remote.exit_code != 0 { error make {msg: 'The current branch must track a remote repository.'} }; \
    let repo = (git remote get-url ($remote.stdout | str trim) | complete); \
    if $repo.exit_code != 0 { error make {msg: ($repo.stderr | str trim)} }; \
    gh workflow run full-matrix.yaml --repo ($repo.stdout | str trim)
