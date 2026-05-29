#!/bin/bash
# =============================================
# Alacritty GNOME Setup for Cargo Install
# Wrapper installed as /usr/local/bin/alacritty
# =============================================

set -euo pipefail

echo "=== Alacritty GNOME Setup (Cargo version) ==="

# Check Cargo binary exists
if [[ ! -f ~/.cargo/bin/alacritty ]]; then
    echo "❌ Error: ~/.cargo/bin/alacritty not found!"
    echo "Please install Alacritty via Cargo first."
    exit 1
fi

# 1. Install wmctrl
echo "→ Installing wmctrl..."
sudo apt update && sudo apt install wmctrl -y

# 2. Create smart wrapper as /usr/local/bin/alacritty
echo "→ Creating smart wrapper at /usr/local/bin/alacritty..."
cat << 'EOF' | sudo tee /usr/local/bin/alacritty > /dev/null
#!/bin/bash
# Smart Alacritty wrapper:
# - Focus existing window if one is running
# - Otherwise launch new instance

if wmctrl -l | grep -q "Alacritty"; then
    wmctrl -xa Alacritty.Alacritty
else
    exec ~/.cargo/bin/alacritty "$@"
fi
EOF

sudo chmod +x /usr/local/bin/alacritty

# 3. Create desktop entry
echo "→ Creating desktop entry..."
cat << EOF | sudo tee /usr/share/applications/Alacritty.desktop > /dev/null
[Desktop Entry]
Version=1.0
Name=Alacritty
Comment=A fast, GPU accelerated terminal emulator
GenericName=Terminal
Exec=/usr/local/bin/alacritty
Icon=Alacritty
Type=Application
Categories=System;TerminalEmulator;
StartupNotify=false
Terminal=false
EOF

# 4. Add icon
echo "→ Adding icon..."
sudo curl -Lo /usr/share/pixmaps/Alacritty.svg \
    https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg 2>/dev/null || true

# 5. Set as default terminal
echo "→ Setting as default terminal..."
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 80
sudo update-alternatives --set x-terminal-emulator /usr/local/bin/alacritty

# 6. GNOME settings
gsettings set org.gnome.desktop.default-applications.terminal exec /usr/local/bin/alacritty
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''

# 7. Refresh desktop database
sudo update-desktop-database

echo "✅ Setup completed!"
echo ""
echo "Now 'alacritty' command and Ctrl + Alt + T are smart:"
echo "→ Focuses existing window if open"
echo "→ Otherwise starts a new one"
