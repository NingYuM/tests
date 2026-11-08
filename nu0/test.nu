
const SKILL = 'pptx-nova'
const REPO = 'hustcer/pptx-nova'
const AGENTS = [claude-code cursor opencode codex]

def install-skill [] {
  with-env { CI: '' GITHUB_ACTIONS: '' } {
    npx skills add -y -g $REPO --skill $SKILL -a ...$AGENTS | complete
  }
}

def remove-skill [] {
  npx skills remove -y -g $SKILL | complete
}

# Install the skill, then repeatedly uninstall and reinstall it.
def main [
  --times (-n): int = 1   # Number of uninstall/reinstall cycles
] {
  mut failures = []
  let first = install-skill
  if $first.exit_code != 0 {
    error make { msg: $'Initial install failed: ($first.stderr | str trim)' }
  }

  for i in 1..$times {
    sleep 0.5sec
    let rm = remove-skill
    let add = install-skill
    print $'[($i)/($times)] remove: ($rm.exit_code), install: ($add.exit_code)'
    if $rm.exit_code != 0 or $add.exit_code != 0 {
      $failures ++= [{ cycle: $i, remove: $rm.exit_code, install: $add.exit_code }]
    }
  }

  if ($failures | is-empty) {
    print $'(ansi g)All ($times) cycles succeeded.(ansi rst)'
  } else {
    print $'(ansi r)($failures | length) cycle\(s\) failed:(ansi rst)'
    print $failures
    exit 1
  }
}
