#!/usr/bin/env bash
# Setup protonmail as default mailto application using Brave browser.
#

dst=~/.local/share/applications/
cat <<EOF >"$dst/brave-protonmail.desktop"
[Desktop Entry]
Name=Brave ProtonMail
Exec=/snap/bin/brave "https://mail.proton.me/u/0/compose?to=%u"
Type=Application
Terminal=false
MimeType=x-scheme-handler/mailto;
NoDisplay=true
EOF

update-desktop-database $dst
xdg-mime default brave-protonmail.desktop x-scheme-handler/mailto
xdg-settings get default-url-scheme-handler mailto
