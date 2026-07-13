{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = "bytedance";
  home.homeDirectory = "/Users/bytedance";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    yazi      # terminal file manager
    lazygit
    neovim
    emacs
    # language toolchains
    go_1_25   # go compiler + tooling (pinned to 1.25)
    python3   # python interpreter
    python3Packages.ipython  # enhanced python repl
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    enableCompletion = true;           # tab completion (compinit)
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.git.settings.user = {
    name = "Zhiyuan Yin";
    email = "zhiyuan.yin@bytedance.com";
  };

  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     add_newline = false;
  #     format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
  #     character = {
  #       success_symbol = "[❯](purple)";
  #       error_symbol = "[❯](red)";
  #     };
  #     cmd_duration.format = "[$duration]($style) ";
  #   };
  # };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".local/bin/dotfiles-sync-fork.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.local/bin/dotfiles-sync-fork.sh";

  # Weekly: rebase local main onto origin/main and push to the fork.
  # Aborts + notifies on conflict instead of force-pushing a broken tree.
  launchd.agents.dotfiles-sync-fork = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/bash"
        "${config.home.homeDirectory}/.local/bin/dotfiles-sync-fork.sh"
      ];
      StartCalendarInterval = [
        { Weekday = 0; Hour = 16; Minute = 0; }  # Sunday 16:00 local
      ];
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/dotfiles-sync-fork.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/dotfiles-sync-fork.log";
    };
  };
}
