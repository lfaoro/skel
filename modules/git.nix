# Git configuration module.
#
# Usage:
#   imports = [ ./modules/git.nix ];
#
# This includes:
# - programs.git (user.name/email from config.nix, aliases, signing, etc.)
# - xdg git/ignore (global excludesfile, kept in sync with core.excludesfile)

{
  config,
  pkgs,
  lib,
  ...
}:

let
  configOpt = import ../config.nix;
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = configOpt.gitName;
      user.email = configOpt.gitEmail;

      core.editor = "hx";
      # Points at the file deployed via xdg.configFile below.
      # (We no longer use the legacy ~/.gitignore_global path.)
      core.excludesfile = "${config.xdg.configHome}/git/ignore";

      alias.co = "checkout";
      alias.br = "branch";
      alias.ci = "commit";
      alias.st = "status";
      alias.lg = "log --oneline --graph --decorate --all";

      credential.helper = "cache --timeout=3600";
      color.ui = "auto";
      pull.rebase = "false";
      push.default = "simple";
    };

    signing = lib.optionalAttrs (configOpt.gitGpgKey != "") {
      format = "openpgp";
      key = configOpt.gitGpgKey;
      signByDefault = configOpt.gitSignByDefault;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      syntax-theme = "Catppuccin Mocha";
      line-numbers = true;
      navigate = true;
      side-by-side = false;
    };
  };

  xdg.configFile."git/ignore".text = ''
    # Compiled source #
    ###################
    *.com
    *.class
    *.dll
    *.exe
    *.o
    *.so

    # Packages #
    ############
    *.7z
    *.dmg
    *.gz
    *.iso
    *.jar
    *.rar
    *.tar
    *.zip

    # Logs and databases #
    ######################
    *.log
    *.sql
    *.sqlite

    # OS generated files #
    ######################
    .DS_Store
    .DS_Store?
    Thumbs.db
    ehthumbs.db
    Desktop.ini
    .Spotlight-V100
    .Trashes
    ._.DS_Store
    ._*
  '';
}
