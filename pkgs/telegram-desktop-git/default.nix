{ final, prev, gitOverride, tg-owt_git, glib_git, glibmm_git, ... }:

gitOverride {
  newInputs = {
    # I hope I don't go to robot-hell bc of this:
    callPackage = file: args:
      let
        realCall = final.callPackage file args;
      in
      if builtins.baseNameOf file == "tg_owt.nix" then
        tg-owt_git
      else
        realCall;
    glibmm_2_68 = glibmm_git;
  };
  nyxKey = "telegram-desktop_git";
  versionNyxPath = "pkgs/telegram-desktop-git/version.json";
  versionLocalPath = ./version.json;
  prev = prev.telegram-desktop;
  fetcher =
    _prevAttrs: finalArgs: final.fetchFromGitHub ({
      owner = "telegramdesktop";
      repo = "tdesktop";
    } // finalArgs);
  fetchLatestRev = src: final.callPackage ../../shared/github-rev-fetcher.nix { inherit src; ref = "dev"; };
  hasSubmodules = true;

  postOverrides = [
    (prevAttrs: {
      postFixup = ''
        qtWrapperArgs+=(
          --prefix LD_LIBRARY_PATH : "${glib_git.out}/lib"
        )
      '' + prevAttrs.postFixup;
    })
  ];
}
