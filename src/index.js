const { app, BrowserWindow, session } = require('electron');

function createWindow () {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
    },
  });

  win.loadURL('https://teams.microsoft.com/v2/');

  // Mantém status “Disponível”
  win.webContents.on('did-finish-load', () => {
    win.webContents.executeJavaScript(`
      setInterval(() => {
        document.dispatchEvent(new MouseEvent('mousemove'));
      }, 5000);
    `);
  });
}

// 🔑 Libera permissão de áudio/vídeo só para o Teams
function setupPermissions () {
  session.defaultSession.setPermissionRequestHandler(
    (wc, permission, callback, details) => {
      // details.requestingUrl → ex.: "https://teams.microsoft.com/"
      const isTeams = details.requestingUrl.startsWith('https://teams.microsoft.com');

      if (isTeams && permission === 'media') {
        return callback(true);            // concede câmera + microfone
      }
      // recusa qualquer outra permissão
      return callback(false);
    }
  );
}

app.whenReady().then(() => {
  setupPermissions();
  createWindow();
});
