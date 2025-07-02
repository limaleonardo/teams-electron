const { app, BrowserWindow } = require('electron');

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

  win.webContents.on('did-finish-load', () => {
    win.webContents.executeJavaScript(`
      setInterval(() => {
        document.dispatchEvent(new MouseEvent('mousemove'));
      }, 5000);
    `);
  });
}

app.whenReady().then(createWindow);
