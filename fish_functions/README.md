# fish_functions

Copy to `~/.config/fish/functions`

***

Issue following commands to update `~/.config/fish/fish_variables` with exportable environment variables.

```bash
set -Ux EXA_COLORS 'da=38;5;12:gm=38;5;12:di=38;5;12;01'
```

```bash
set -Ux GH_USER 'lukasz-lobocki'
```

```bash
set -Ux GH_TOKEN 'ghp...'
```

***

Issue to populate fish's PATH

```bash
fish_add_path -m /usr/local/bin /usr/bin /home/lukasz/.local/bin /bin /usr/local/go/bin /snap/bin /sbin /usr/sbin
```
