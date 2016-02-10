# BBI commands
> https://bitbucket.org/jsmits/bitbucket-issues-cli

```bash
(bbi)[jsmits@imac:~]$ bbi --help
Usage: bbi command [args] [options]

Examples:
bbi                                 show all open issues
bbi -v                              same as above, but with issue details
bbi -w                              show issues' Bitbucket page in web browser
bbi <nr>                            show issue <nr>
bbi <nr> -w                         show issue <nr>'s Bitbucket page in web
                                    browser
bbi new (n)                         create a new issue (with $EDITOR)
bbi new (n) -m <msg>                create a new issue with <msg> content
                                    (optionally, use \n for new lines; first
                                    line will be the issue title)
bbi edit (e) <nr>                   edit issue <nr> (with $EDITOR)
bbi close (c) <nr>                  close issue <nr> (closing status is asked
                                    for)
bbi open (o) <nr>                   (re)open issue <nr>
bbi remove (rm) <nr>                remove issue <nr>
bbi search (s) <term>               search for <term>
bbi -r <user>/<repo>                specify a repository (can be used for
                                    all commands)
bbi -r <repo>                       specify a repository (gets user from
                                    $HOME/.bbi config file)

Description: command-line interface to Bitbucket's Issues API

Options:
  -h, --help            show this help message and exit
  -v, --verbose         show issue details [default: False]
  -m MESSAGE, --message=MESSAGE
                        message content for opening an issue without using the
                        editor
  -r REPO, --repo=REPO, --repository=REPO
                        specify a repository (format: `user/repo` or just
                        `repo` (latter will get the user from the $HOME/.bbi
                        config file))
  -w, --web, --webbrowser
                        show issue(s) Bitbucket page in web browser (only for
                        list and show commands) [default: False]
  -V, --version         show program's version number and exit
```