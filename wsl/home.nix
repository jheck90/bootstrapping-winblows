{ config
, pkgs
, username
, nix-index-database
, nix-vscode-extensions
, ...
}:
let
  unstable-packages = with pkgs.unstable; [
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    killall
    lunarvim
    mosh
    mlocate
    neovim
    procs
    ripgrep
    sd
    tmux
    tree
    unzip
    vim
    wget
    zip
    keybase
  ];

  stable-packages = with  pkgs; [

    # key tools
    gh
    just
    awscli2
    ssm-session-manager-plugin
    taskwarrior
    gopass
    csvq
    restic
    pipx
    pwgen
    chezmoi
    packer
    rclone
    drone-cli
    nomad
    pre-commit
    nomad
    terraform-docs
    terraform
    tfswitch
    gnumake
    wslu

    # core languages
    rustup
    go
    lua
    nodejs
    python3
    typescript

    # rust
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie
    ran
    rsync
    unzip
    jq
    yq
    grex
    gron
    watchexec

    # language servers
    ccls # c / c++
    gopls
    gdlv
    nodePackages.typescript-language-server
    pkgs.nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    sumneko-lua-language-server
    nil # nix
    nodePackages.pyright

    # formatters and linters
    alejandra # nix
    black # python
    ruff # python
    nixpkgs-fmt # nix
    golangci-lint
    lua52Packages.luacheck
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
    sqlfluff
    tflint
    hclfmt
  ];

  extensionsList = with nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
    # Golang
    golang.go

    # Terrafom
    hashicorp.terraform
    hashicorp.hcl

    # Python
    ms-python.python

    # Java
    redhat.java
    vscjava.vscode-lombok

    # Nix
    jnoortheen.nix-ide

    # Generic language parsers / prettifiers
    esbenp.prettier-vscode
    redhat.vscode-yaml
    jkillian.custom-local-formatters

    # Generic tools
    eamodio.gitlens
    jebbs.plantuml

    # DB stuff
    mtxr.sqltools
    mtxr.sqltools-driver-pg

    # Eye candy
    pkief.material-icon-theme
    zhuangtongfa.material-theme

    # Misc
    jkillian.custom-local-formatters
  ];

in
{
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home = {
    username = "${ username}";
    homeDirectory = "/home/${ username}";
    stateVersion = "22.11";
    sessionVariables. EDITOR = "vim";
    sessionVariables. SHELL = "/etc/profiles/per-user/${username}/bin/zsh";
    packages = stable-packages ++ unstable-packages ++ extensionsList ++ [
      (pkgs.callPackage ../modules/codegpt.nix { })
      (pkgs.callPackage ../modules/go-markdown2confluence.nix { })
    ];
  };

  home.file = {
    workspaces.source = config.lib.file.mkOutOfStoreSymlink "/mnt/c/Users/${username}/Documents/workspaces";
    workspaces.target = "workspaces";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 3600;
    pinentryFlavor = "tty";
    enableScDaemon = false;
  };

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableZshIntegration = true;
    nix-index-database.comma.enable = true;

    gpg.enable = true;

    fzf.enable = true;
    fzf.enableZshIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;
    broot.enable = true;
    broot.enableZshIntegration = true;

    vscode = {
      enable = true;
      extensions = extensionsList;
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = true;

      keybindings = [
        {
          key = "ctrl+q";
          command = "editor.action.commentLine";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+d";
          command = "editor.action.copyLinesDownAction";
          when = "editorTextFocus && !editorReadonly";
        }
      ];

      userSettings = {
        "workbench.colorTheme" = "Visual Studio Dark";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "newUntitledFile";
        "editor.renderWhitespace" = "all";
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
        "extensions.ignoreRecommendations" = true;
        "extensions.autoCheckUpdates" = false;
        "explorer.confirmDelete" = false;
        "extensions.autoUpdate" = false;
        "files.watcherExclude" = {
          "**/vendor/**" = true;
          "**/.config/**" = true;
        };
        "gitlens.mode.statusBar.enabled" = false;
        "gitlens.hovers.currentLine.over" = "line";
        "explorer.confirmDragAndDrop" = false;
        "redhat.telemetry.enabled" = false;
        "telemetry.telemetryLevel" = "off";
        "files.associations" = {
          "*.hcl" = "hcl";
          "*.nomad.hcl" = "hcl";
          "*.pkr.hcl" = "hcl";
        };
        "customLocalFormatters.formatters" = [
          {
            "command" = "${pkgs.terraform}/bin/terraform fmt -";
            "languages" = [
              "terraform"
            ];
          }
          {
            "command" = "${pkgs.nomad}/bin/nomad fmt -";
            "languages" = [
              "nomad"
            ];
          }
          {
            "command" = "${pkgs.hclfmt}/bin/hclfmt";
            "languages" = [
              "hcl"
            ];
          }
        ];
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "nixpkgs-fmt";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = { "command" = [ "nixpkgs-fmt" ]; };
          };
        };
      };
    };

    direnv.enable = true;
    direnv.enableZshIntegration = true;
    direnv.nix-direnv.enable = true;

    zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      defaultKeymap = "emacs";
      history.size = 10000;
      history.save = 10000;
      history.expireDuplicatesFirst = true;
      history.ignoreDups = true;
      history.ignoreSpace = true;
      historySubstringSearch.enable = true;

      shellAliases = {
        gc = "nix-collect-garbage --delete-old";
        show_path = "echo $PATH | tr ':' '\n'";

        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
      };

      envExtra = ''
        export PATH=$PATH:$HOME/.local/bin
      '';

      initExtra = ''
        # fixes duplication of commands when using tab-completion
        export LANG=C.UTF-8

        autoload -U +X compinit && compinit
        autoload -U +X bashcompinit && bashcompinit

        for f in $(find ~/.bashrc.d -type f | sort -r ); do
            source $f || echo "[$f] could not load - exit code $?"
        done

        awssso-populate-profiles () {
          aws-sso-util configure populate -u https://gofigg.awsapps.com/start --sso-region us-east-1 --region us-east-1 -c output=json --no-credential-process
        }

        awssso-export () {
          eval $(awssso-get-credentials --env-export)
        }

        awssso-unexport () {
          unset AWS_ACCESS_KEY_ID
          unset AWS_SECRET_ACCESS_KEY
          unset AWS_SESSION_TOKEN
        }

        awssso-logout() {
          aws sso logout --profile ${AWS_PROFILE}
          unset AWS_PROFILE
          unset AWS_REGION
          unset AWS_ACCOUNT
        }

        awssso() {
          # requires:
          # - aws cli v2

          if [[ -z "$AWS_CONFIG_FILE" ]]
          then
            local AWS_CONFIG_FILE=~/.aws/config
          fi

          export AWS_PROFILE=${1}
          export AWS_REGION=$(cat ${AWS_CONFIG_FILE} | grep -A20 "$AWS_PROFILE" | grep sso_region | awk '{print $3}' | head -1)
          export AWS_ACCOUNT=$(cat ${AWS_CONFIG_FILE} | grep -A20 "$AWS_PROFILE" | grep sso_account_id | awk '{print $3}' | head -1)

          # Login only if there is no active sso session for the specified profile
          aws sts get-caller-identity >/dev/null 2>&1
          if [ ! $? -eq 0 ]; then
            aws sso login --profile ${AWS_PROFILE}
          fi
        }

        _awssso() {
          local cur
          COMPREPLY=()
          cur=${COMP_WORDS[COMP_CWORD]}

          if [[ -z "$AWS_CONFIG_FILE" ]]
          then
            local AWS_CONFIG_FILE=~/.aws/config
          fi
          
          WORDS="$(cat ${AWS_CONFIG_FILE} | grep "^\[profile " | sed 's/\[profile //;s/\]//')"
          case "$cur" in
          *)
            COMPREPLY=($(compgen -W "$WORDS" -- "$cur"))
            ;;
          esac
        }

        complete -F _awssso awssso


        # Takes my profile, and iterates over every ec2, lists them out, etc
        _ssm() {
          local cur
          COMPREPLY=()
          cur=${COMP_WORDS[COMP_CWORD]}
          WORDS="$(aws ec2 describe-instances \
          --filters Name=instance-state-code,Values=16 Name=tag:Environment,Values=ops,qa,uat,prd \
          | jq '.[][].Instances[] | "\(.Tags | map( { (.Key): .Value } ) | add | .Name),\(.InstanceId)"' \
          | tr -s ' ' | tr ' ' '_' | tr '[A-Z]' '[a-z]')"
          case "$cur" in
            *)
              COMPREPLY=($(compgen -W "$WORDS" -- "$cur"))
              ;;
          esac
        }

        function ssm() {
          echo $@ # echo qa-reporting,i-001049e7574afdac7
          target=$(echo $@ | awk -F ',' '{print $2}') # i-001049e7574afdac7
          aws ssm start-session --target $target

        }

        complete -F _ssm ssm

        _awssso-get-credentials() {
          SSO_ROLE_NAME=$(aws configure get sso_role_name)
          SSO_ACCOUNT_ID=$(aws configure get sso_account_id)
          SSO_START_URL=$(aws configure get sso_start_url)
          TOKEN=$(cat ~/.aws/sso/cache/*.json | jq -rs --arg SSO_START_URL "$SSO_START_URL" '.[] | select(.startUrl == $SSO_START_URL) | .accessToken')
          aws sso get-role-credentials --role-name "$SSO_ROLE_NAME" --account-id "$SSO_ACCOUNT_ID" --access-token "$TOKEN"
        }

        awssso-get-credentials() {
          AUTH=$(_awssso-get-credentials)

          cat <<EOF
        export AWS_DEFAULT_REGION=$(aws configure get region)
        export AWS_ACCESS_KEY_ID=$(echo "$AUTH" | jq -r '.roleCredentials.accessKeyId')
        export AWS_SECRET_ACCESS_KEY=$(echo "$AUTH" | jq -r '.roleCredentials.secretAccessKey')
        export AWS_SESSION_TOKEN=$(echo "$AUTH" | jq -r '.roleCredentials.sessionToken')
        EOF
        }

        alias t="./terraform.sh"

        _t() {

            NAMESPACE_DIR=$(ls | grep namespaces)

            WORKSPACE_DIR=$(ls | grep environments)
            if [ ! ${WORKSPACE_DIR} ]; then
                WORKSPACE_DIR=$(ls | grep workspaces)
            fi

            local cur prev

            cur=${COMP_WORDS[COMP_CWORD]}
            prev=${COMP_WORDS[COMP_CWORD-1]}
            prev_prev=${COMP_WORDS[COMP_CWORD-2]}

            case ${COMP_CWORD} in
                1)
                    if [ ${NAMESPACE_DIR} ]; then
                        WORDS="$(ls $(pwd)/${NAMESPACE_DIR})"
                    else
                        WORDS="$(ls $(pwd)/${WORKSPACE_DIR})"
                    fi
                    
                    COMPREPLY=($(compgen -W "$WORDS" -- "${cur}"))
                    ;;
                2)
                    if [ ${NAMESPACE_DIR} ]; then
                        WORDS="$(ls $(pwd)/${NAMESPACE_DIR}/${prev})"
                    else
                        WORDS="$(find $(pwd)/${WORKSPACE_DIR}/${prev} -type f -name '*.tf' -not -path '*.terraform/*' | sed -r 's|/[^/]+$||' | sort | uniq | sed 's|'`pwd`'/'${WORKSPACE_DIR}'/'${prev}'/||g')"
                    fi
                    
                    COMPREPLY=($(compgen -W "$WORDS" -- "${cur}"))
                    ;;
                3)
                    if [ ${NAMESPACE_DIR} ]; then
                        WORDS="$(ls $(pwd)/${NAMESPACE_DIR}/${prev_prev}/${prev})"
                        WORDS="$(find $(pwd)/${NAMESPACE_DIR}/${prev_prev}/${prev} -type f -name '*.tf' -not -path '*.terraform/*' | sed -r 's|/[^/]+$||' | sort | uniq | sed 's|'`pwd`'/'${NAMESPACE_DIR}'/'${prev_prev}'/'${prev}'/||g')"
                        COMPREPLY=($(compgen -W "$WORDS" -- "${cur}"))
                    fi
                    ;;
            esac
        }

        complete -F _t t

        dockerLoginECR () {
          ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text) 
          REGION=$(aws configure get region) 
          aws ecr get-login-password | sudo docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
        }

        git_flatten () {
          git reset $(git merge-base master `git branch | grep '*' | cut -d ' ' -f2`)
          git add -A
          echo "#############################################################################"
          echo "#  Write your new, singular commit message, and then force push to origin."
          echo "#  Like this:"
          echo "#  git commit -m 'COMPRESSED_MESSAGE'"
          echo "#  git push -u origin $(git branch | grep '*' | cut -d ' ' -f2) --force"
          echo "#############################################################################"
        }

        # copy to clipboard on lookup
        alias 2="gopass otp -o --clip"

        complete -F _gopass_bash_autocomplete 2

        vpn_figg () {
          echo $(2 websites/openvpn.ops.i-edo.net/jcasillas) | xsel -ib
          sudo openvpn --config ~/.ssh/keys/figg/client.ovpn --auth-user-pass ~/.ssh/keys/figg/openvpn_creds --auth-nocache
        }

        # cheat COMMAND
        cheat() { clear -x && curl cheat.sh/"$1" ; }

        source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
        # Created by `pipx` on 2023-03-27 18:27:59
        export PATH="$PATH:/home/jheck90/.local/bin"


        aws-search-tags () {
          if [ -z "$1" ]; then
            # display usage if no params are given
            echo "Usage: aws-search-tags Environment qa"
            echo "Returns all resources in JSON format that match the tag <key> and <value> provided."
            return 1
          else
            aws resourcegroupstaggingapi get-resources --tag-filters Key=$1,Values=$2 
          fi
        }

        aws-bounce-ecs () {
          if [ -z "$1" ]; then
            # display usage if no params are given
            echo "Usage: aws-bounce-ecs qa grafana"
            echo "Gracefully restarts the target service."
            return 1
          else
            aws ecs update-service --service $2 --cluster $1 --force-new-deployment
          fi
        }

        alias ssm_uat_jpos_inbound='aws ssm start-session --target mi-04542c8a4d3ce6c1a'
        alias ssm_uat_jpos_outbound='aws ssm start-session --target mi-06bae2064e988e84a'
        alias ssm_prd_jpos_inbound='aws ssm start-session --target mi-002ea05a8242253e6'
        alias ssm_prd_jpos_outbound='aws ssm start-session --target mi-051f9daf1853d193a'

        eval "$(direnv hook zsh)"

        launch_test_ec2_instance() {

          local suicide_time=${1:-55}
          local image_id=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-kernel-*-x86_64-gp2" --query 'sort_by(Images, &CreationDate)[0].ImageId' --output text)
          local subnet_id=$(aws ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text)
          local user_data=$(echo -e '#!/bin/bash\n\necho "sudo halt" | at now + '$suicide_time 'minutes')

          local instance_id=$(aws ec2 run-instances \
            --image-id "$image_id" \
            --instance-type t2.micro \
            --subnet-id "$subnet_id" \
            --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$(whoami)-test'},{Key=PatchGroup,Value=default}]' \
            --instance-initiated-shutdown-behavior terminate \
            --metadata-options HttpEndpoint=enabled,HttpTokens=required \
            --instance-market-options '{"MarketType": "spot", "SpotOptions": {"MaxPrice": "0.1", "SpotInstanceType": "one-time"}}' \
            --user-data "$user_data" \
            --query 'Instances[0].InstanceId' \
            --output text
          )

          local termination_time=$(date -d "+$suicide_time minutes" '+%Y-%m-%d %H:%M')

          echo "Instance ID: $instance_id"
          echo "Expected Termination Time: $termination_time"
        }

        dockerRehostImage () {
          ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text) 
          REGION=$(aws configure get region) 
          IMAGE=${1} 
          TAG=${2}
          EXISTING_ECR=${3}
          
          docker pull ${IMAGE}:${TAG}

          if [ -n "${EXISTING_ECR}" ]; then
            aws ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
            ECR_REPO_URI="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${EXISTING_ECR}" 
          else
            aws ecr create-repository --repository-name ${IMAGE} || true
            aws ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
            ECR_REPO_URI="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE}" 
          fi

          docker image tag ${IMAGE}:${TAG} ${ECR_REPO_URI}/${IMAGE}:${TAG}
          echo "Pushing to ECR...${ECR_REPO_URI}/${IMAGE}:${TAG}"
          docker push ${ECR_REPO_URI}/${IMAGE}:${TAG}
        }

        alias tf="terraform_change_dir"
        terraform_change_dir() {
          cd /home/jheck90/tf
        }

        alias repos="repos_change_dir"
        repos_change_dir() {
          cd /home/jheck90/repos
        }

        cheat() { curl cheat.sh/$1 ;}
      '';
    };
  };
}
