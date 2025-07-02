#!/bin/bash

set -e

APP_NAME="teams-electron"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
REPO_URL="https://github.com/SEU_USUARIO/SEU_REPO"
REPO_ZIP="$REPO_URL/archive/refs/heads/main.zip"
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

# Detecta o nome do diretório extraído (ex: repo-main)
SRC_DIR=$(find . -maxdepth 1 -type d -name "*-main" | head -n1)

echo "📦 Instalando dependências do Electron..."
cd "$SRC_DIR"
npm install

echo "🔒 Corrigindo permissões do chrome-sandbox..."
sudo chown root node_modules/electron/dist/chrome-sandbox
sudo chmod 4755 node_modules/electron/dist/chrome-sandbox

echo "🖼️ Copiando ícone..."
cp teams-icon.png "$ICON_PATH"

echo "🧷 Criando atalho na área de trabalho..."
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Microsoft Teams Web
Exec=npm start --prefix=$INSTALL_DIR/$SRC_DIR
Icon=$ICON_PATH
Type=Application
Categories=Network;Chat;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

echo "✅ Instalação concluída!"
echo "Você pode abrir o Teams Web pelo menu de aplicativos 🎉"
