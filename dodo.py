from os import chmod
import stat

commit_msg_hook = """
#!/bin/sh

commit_regex="\[.*#\d+.*\]"
error_msg="Aborting commit. Your commit message is missing a PivotalTracker Story ID ('[#123]')"

if ! grep -qE "$commit_regex" "$1"; then
    echo "$error_msg" >&2
    exit 1
fi
"""

def task_install_hook():
    """Install git hooks"""
    def install_hook(targets):
        with open(targets[0], 'w') as output:
            output.write(commit_msg_hook)
        chmod(targets[0], stat.S_IRWXU)

    return {
        'doc': "Install git hook to check for story IDs in commit messages",
        'actions': [install_hook],
        'file_dep': [__file__],
        'targets': ['.git/hooks/commit-msg']
    }
