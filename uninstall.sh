#!/bin/bash

echo "🚮 Removendo wrapper Teams Web..."

APP_NAME="teams-electron"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
WRAPPER_PATH="$HOME/.local/bin/teams-web"
ICON_PATH="$INSTALL_DIR/teams-icon.png"

# Remove arquivos
rm -rf "$INSTALL_DIR"
rm -f "$DESKTOP_FILE"
rm -f "$WRAPPER_PATH"

# Opcional: remove cache do desktop
update-desktop-database ~/.local/share/applications/

echo "✅ Desinstalação concluída!"
