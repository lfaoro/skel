{ pkgs, ... }:
{
  programs.librewolf = {
    enable = true;
    package = pkgs.librewolf;

    # Settings derived from your prefs.js
    settings = {
      # Accessibility
      "accessibility.typeaheadfind.flashBar" = 0;

      # Bookmarks
      "browser.bookmarks.addedImportButton" = true;
      "browser.bookmarks.restore_default_bookmarks" = false;

      # Content Blocking
      "browser.contentblocking.category" = "strict";

      # UI and Behavior
      "browser.ctrlTab.sortByRecentlyUsed" = true;
      "browser.display.use_document_fonts" = 0; # Enforces your font choice
      "browser.dom.window.dump.enabled" = false;
      "browser.download.panel.shown" = true;
      "browser.download.viewableInternally.typeWasRegistered.avif" = true;
      "browser.download.viewableInternally.typeWasRegistered.webp" = true;
      "browser.startup.page" = 3; # Restore previous session
      "browser.tabs.inTitlebar" = 1;
      "browser.theme.content-theme" = 0; # Dark theme
      "browser.theme.toolbar-theme" = 0;
      "browser.toolbars.bookmarks.visibility" = "newtab";
      "browser.warnOnQuitShortcut" = false;

      # Font Settings (from your prefs.js)
      "font.default.x-western" = "sans-serif";
      "font.name.monospace.x-western" = "Hack Nerd Font";
      "font.name.sans-serif.x-western" = "Hack Nerd Font";
      "font.name.serif.x-western" = "Hack Nerd Font";

      # Privacy and Security
      "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
      "browser.safebrowsing.downloads.remote.block_uncommon" = false;
      "browser.safebrowsing.downloads.remote.enabled" = false;
      "browser.region.update.enabled" = false;
      "dom.forms.autocomplete.formautofill" = true;
      "dom.private-attribution.submission.enabled" = false;
      "dom.security.https_only_mode_ever_enabled" = true;
      "network.captive-portal-service.enabled" = false;
      "network.connectivity-service.enabled" = false;
      "network.cookie.cookieBehavior.optInPartitioning" = true;
      "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;
      "network.http.speculative-parallel-limit" = 0;
      "network.predictor.enabled" = false;
      "network.prefetch-next" = false;
      "privacy.annotate_channels.strict_list.enabled" = true;
      "privacy.bounceTrackingProtection.mode" = 1;
      "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
      "privacy.clearOnShutdown_v2.cache" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "privacy.fingerprintingProtection" = true;
      "privacy.globalprivacycontrol.was_ever_enabled" = true;
      "privacy.history.custom" = true;
      "privacy.query_stripping.enabled" = true;
      "privacy.query_stripping.enabled.pbmode" = true;
      "privacy.sanitize.sanitizeOnShutdown" = false;
      "privacy.trackingprotection.emailtracking.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "security.tls.enable_0rtt_data" = false;

      # Search and Policies
      "browser.urlbar.placeholderName" = "DuckDuckGo";
      "browser.urlbar.placeholderName.private" = "DuckDuckGo";
      "browser.policies.applied" = true;

      # Developer Tools
      "devtools.cache.disabled" = true;
      "devtools.console.stdout.chrome" = false;
      "devtools.debugger.remote-enabled" = false;
      "devtools.responsive.reloadNotification.enabled" = false;

      # Extensions
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
      "extensions.webcompat.enable_shims" = true;
      "extensions.webcompat.perform_injections" = true;

      # Media
      "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
      "media.videocontrols.picture-in-picture.video-toggle.has-used" = true;

      # Permissions
      "permissions.default.geo" = 2; # Deny geolocation
      "permissions.delegation.enabled" = false;
    };
  };
}
