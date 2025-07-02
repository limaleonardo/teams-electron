// src/index.js
const { app, BrowserWindow, session, desktopCapturer } = require('electron');

// 1) Flags de WebRTC / PipeWire
app.commandLine.appendSwitch('enable-features', 'WebRTCPipeWireCapturer');
// opcional: app.commandLine.appendSwitch('autoplay-policy','no-user-gesture-required');

function allowMediaPermission(permission, details = {}) {
  // libera camera/mic/getDisplayMedia
  if (!['media','display-capture'].includes(permission)) return false;
  // para detalhes de enumerateDevices
  if (permission === 'display-capture') return true;
  const { mediaTypes = [], mediaType } = details;
  const types = mediaTypes.length ? mediaTypes : [mediaType];
  return types.some(t => ['video','audio','camera','microphone','screen'].includes(t));
}

function setupPermissions() {
  // 2.1 Quando o site PEDE permissão (getUserMedia ou getDisplayMedia)
  session.defaultSession.setPermissionRequestHandler(
    (_wc, perm, callback, details) => {
      callback(allowMediaPermission(perm, details));
    }
  );

  // 2.2 Quando o site CHECA "já tenho permissão?"
  session.defaultSession.setPermissionCheckHandler(
    (_wc, perm, details) => allowMediaPermission(perm, details)
  );

  // 2.3 enumerateDevices → libera audio/video/display
  session.defaultSession.setDevicePermissionHandler(details => (
    ['videoCapture','audioCapture','displayCapture'].includes(details.deviceType)
  ));

  // 3) Intercepta getDisplayMedia() e fornece um DesktopCapturerSource
  session.defaultSession.setDisplayMediaRequestHandler(
    async (request, callback) => {
      try {
        const sources = await desktopCapturer.getSources({
          types: ['screen','window']
        });
        // aprova sempre a primeira tela inteira
        callback({ video: sources[0] });
      } catch (e) {
        console.error('[Teams-wrapper] display media handler error', e);
        callback({});  // nega
      }
    }
    // , { useSystemPicker: false } // macOS experimental
  );
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1200, height: 800,
    webPreferences: { nodeIntegration: false, contextIsolation: true }
  });

  // 4) Spoof do UA pra aparecer a aba Dispositivos no Teams
  const spoofUA =
    'Mozilla/5.0 (X11; Linux x86_64) ' +
    'AppleWebKit/537.36 (KHTML, like Gecko) ' +
    'Chrome/126.0.0.0 Safari/537.36';
  win.webContents.setUserAgent(spoofUA);

  win.loadURL('https://teams.microsoft.com/v2/');

  // 5) keep-alive de status “Disponível”
  win.webContents.on('did-finish-load', () => {
    win.webContents.executeJavaScript(`
      setInterval(()=>document.dispatchEvent(new MouseEvent('mousemove')),5000);
    `);
  });
}

app.whenReady().then(() => {
  setupPermissions();
  createWindow();
});
