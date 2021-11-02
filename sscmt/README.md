

# Simple Slack Configuration Management Tool (SCMT)

Do you like consul-template, but wish it had less consul and more YAML? Do you enjoy Chef, but dislike the Ruby DSL?

SSCMT is a configuration management tool that combines the best 1 or 2 parts of Chef and a simple configuration syntax in YAML.


## Design Requirements

 * If your tool has dependencies not available on a standard Ubuntu instance you may include a bootstrap.sh program to resolve them
 * Your tool must provide an abstraction that allows specifying a file's content and metadata (owner, group, mode)
 * Your tool must provide an abstraction that allows installing and removing Debian packages
 * Your tool must provide some mechanism for restarting a service when relevant files or packages are updated
 * Your tool must be idempotent - it must be safe to apply your configuration over and over again
 * Don't forget to document the basic architecture of your tool, how to install it, how to write configurations, and how to invoke them
 * Your configuration must specify a web server capable of running the PHP application below
 * Both servers must respond 200 OK and include the string "Hello, world!" in their response to requests from curl -sv "http://ADDRESS"; ( http://address%22/ ); ( http://address%22 ( http://address%22/ )/ ); (using the public IP address)
 * For the purposes of this challenge, please do not reboot any of the provided servers.


## Install

```sh
# run as root
/bin/sh -c "$(curl -fsSL https://sethrylan.org/files/sscmt/bootstrap.sh)"
```

## Usage

##### Help message
```sh
/opt/sscmt/sscmt.rb -h
```

##### Run configuration with externalized config
```sh
/opt/sscmt/sscmt.rb [-v] -c http://example.org/server-2.0.1.yaml
```

##### Run configuration with local config file
```sh
/opt/sscmt/sscmt.rb [-v] -c config.yaml
```


## Config Format

All properties are required unless marked optional.

```yaml
packages:                              # `packages` is a package manager abstraction
  - name: apache2                      #  the package name
    version: 2.4.29-1ubuntu4.18        #  and (optional) version (defaults to latest version in upstream)
  - name: git                          #
    action: remove                     #  and optional action (defaults to `install`)
files:                                 # `files` is a file creation abstraction
  - path: /var/www/html/index.php      #  the destination directory (created if it doesn't exist)
    source: ./files/index.php          #  the source file on the filesystem (absolute, relative, or http path)
    owner: root                        #  the destination file's owner,
    group: root                        #  and group
    permissions: 0644                  #  and permissions
    after: 'service apache2 reload'    #  and (optional) hook to execute after the file is created (e.g., reload the http server)
after: './validate.sh'                 # (optional) `after` is a hook to run after executing any updates.
```

Each section (packages, files, after) always run in the order seen above, regardless of the order in the config file.


## Feature Roadmap

0. Better schema validation and versioning.
1. Ruby runtime isolation. SSCMT is designed for and tested with Ruby 2.5.1. This may create issues on servers that need different or multiple Ruby versions. This could be addressed using rbenv.
2. Support for additional package systems (currently only supports `apt`).
3. Cleanup the downloaded scripts directory after successful runs.
4. Dry-run support.


apt update
DEBIAN_FRONTEND=noninteractive apt-get install -y libapache2-mod-php=7.2.24-0ubuntu0.18.04.10
DEBIAN_FRONTEND=noninteractive apt-get install -y php=7.2.24-0ubuntu0.18.04.10
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2=2.4.29-1ubuntu4.19



<?php
header("Content-Type: text/plain");
echo "Hello, world!\n";
?>
