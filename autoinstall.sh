#!/bin/bash

set -e

APP_NAME="teams-electron"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
REPO_ZIP="https://github.com/limaleonardo/teams-electron/archive/refs/heads/main.zip"
ICON_PATH="$INSTALL_DIR/teams-icon.png"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"

echo "🔍 Verificando Node.js..."
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "❌ Node.js e/ou npm não encontrados."
  echo "👉 Instale via NVM: https://github.com/nvm-sh/nvm"
  exit 1
fi

echo "📁 Criando diretório de instalação: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "⬇️ Baixando wrapper do repositório..."
curl -L "$REPO_ZIP" -o repo.zip
unzip -o repo.zip
rm repo.zip

# Caminho fixo para onde o repositório é extraído
SRC_DIR="teams-electron-main"
cd "$SRC_DIR"
npm install

echo "🔒 Corrigindo permissões do chrome-sandbox..."
sudo chown root node_modules/electron/dist/chrome-sandbox
sudo chmod 4755 node_modules/electron/dist/chrome-sandbox

echo "🖼️ Copiando ícone..."
cp teams-icon.png "$ICON_PATH"

# 🧾 Criando script de inicialização...
WRAPPER_PATH="$HOME/.local/bin/teams-web"
mkdir -p "$(dirname "$WRAPPER_PATH")"

# Caminho absoluto do npm (instalado via nvm)
NPM_BIN="$(command -v npm)"
NODE_DIR="$(dirname "$NPM_BIN")"   # diretório onde está o node também

cat > "$WRAPPER_PATH" <<EOF
#!/usr/bin/env bash
# Garante que node e npm do NVM estejam no PATH
export PATH="$NODE_DIR:\$PATH"
cd "$INSTALL_DIR/$SRC_DIR"
exec "$NPM_BIN" start
EOF

chmod +x "$WRAPPER_PATH"



echo "🧷 Criando atalho no menu (desktop file)..."
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Microsoft Teams Web
Exec=$WRAPPER_PATH
Icon=$ICON_PATH
Type=Application
Categories=Network;Chat;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"
update-desktop-database ~/.local/share/applications/
