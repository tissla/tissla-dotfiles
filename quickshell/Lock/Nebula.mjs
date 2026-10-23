// Static galaxy texture, generated once per desktop size on a worker thread.
// Keep the pixel loop off the UI thread, including on the first lock.
function base64(bytes) {
  const alphabet =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  const chunks = [];
  let chunk = "";
  for (let i = 0; i < bytes.length; i += 3) {
    const a = bytes[i],
      b = bytes[i + 1] || 0,
      c = bytes[i + 2] || 0;
    chunk +=
      alphabet[a >> 2] +
      alphabet[((a & 3) << 4) | (b >> 4)] +
      (i + 1 < bytes.length ? alphabet[((b & 15) << 2) | (c >> 6)] : "=") +
      (i + 2 < bytes.length ? alphabet[c & 63] : "=");
    if (chunk.length >= 8192) {
      chunks.push(chunk);
      chunk = "";
    }
  }
  chunks.push(chunk);
  return chunks.join("");
}

function render(width, height) {
  const grid = [];
  for (let i = 0; i < 16384; i++) {
    const v = Math.sin((i + 19000) * 127.1 + 311.7) * 43758.5453;
    grid.push(v - Math.floor(v));
  }
  function noise(x, y) {
    const ix = Math.floor(x),
      iy = Math.floor(y);
    let fx = x - ix,
      fy = y - iy;
    fx = fx * fx * (3 - 2 * fx);
    fy = fy * fy * (3 - 2 * fy);
    const a = grid[(iy & 127) * 128 + (ix & 127)];
    const b = grid[(iy & 127) * 128 + ((ix + 1) & 127)];
    const c = grid[((iy + 1) & 127) * 128 + (ix & 127)];
    const d = grid[((iy + 1) & 127) * 128 + ((ix + 1) & 127)];
    return (a + (b - a) * fx) * (1 - fy) + (c + (d - c) * fx) * fy;
  }
  function turbulence(x, y) {
    let value = 0,
      weight = 0.53;
    for (let octave = 0; octave < 5; octave++) {
      value += noise(x, y) * weight;
      x = x * 2.03 + 17.1;
      y = y * 2.03 + 9.2;
      weight *= 0.48;
    }
    return value;
  }

  const step = Math.max(6, Math.ceil(Math.sqrt((width * height) / 250000)));
  const w = Math.ceil(width / step),
    h = Math.ceil(height / step);
  const bytes = new Uint8Array(54 + w * h * 4);
  const header = new DataView(bytes.buffer);
  bytes[0] = 66;
  bytes[1] = 77;
  header.setUint32(2, bytes.length, true);
  header.setUint32(10, 54, true);
  header.setUint32(14, 40, true);
  header.setInt32(18, w, true);
  header.setInt32(22, -h, true); // Top-down, uncompressed 32-bit BMP.
  header.setUint16(26, 1, true);
  header.setUint16(28, 32, true);
  const worldHeight = height;
  for (let y = 0; y < h; y++) {
    const worldY = y * step;
    const v = worldY / worldHeight;
    for (let x = 0; x < w; x++) {
      const worldX = x * step;
      const u = worldX / worldHeight;
      const t = worldX / width;
      const warp = noise(u * 3 + 31, v * 3 + 17);
      const center = 0.94 - 0.86 * t + 0.055 * Math.sin(t * 8);
      const offset = v - center + (warp - 0.5) * 0.14;
      const envelope = Math.exp((-offset * offset) / 0.025);
      const gas = turbulence(u * 6 + warp * 2, v * 6 + 53);
      const detail = noise(u * 55 + gas * 3, v * 55);
      const lane =
        offset + Math.sin(u * 7 + gas * 5) * 0.035 + (detail - 0.5) * 0.016;
      const laneWidth = 0.012 + noise(u * 9, v * 9 + 81) * 0.035;
      const dust = Math.exp((-lane * lane) / (laneWidth * laneWidth));
      const branches = Math.pow(noise(u * 19 + warp * 5, v * 19 + 7), 3);
      const light =
        envelope *
        Math.pow(gas, 2.7) *
        3.8 *
        (1 - dust * 0.78) *
        (1 - branches * 0.8) *
        (0.8 + detail * 0.4);
      const warm = Math.max(0, 1 - t * 2.8);
      const cyan = noise(u * 4 + 91, v * 4) * Math.min(1, t * 2);
      const pink = Math.pow(noise(u * 7 + 15, v * 7 + 21), 3);
      const i = 54 + (y * w + x) * 4;
      bytes[i] = Math.min(255, 17 + light * (190 - warm * 95 + cyan * 60));
      bytes[i + 1] = Math.min(
        255,
        7 + light * (95 + warm * 35 + cyan * 110 - pink * 30),
      );
      bytes[i + 2] = Math.min(
        255,
        4 + light * (70 + warm * 170 + pink * 130 - cyan * 25),
      );
      bytes[i + 3] = 255;
    }
  }
  return {
    source: "data:image/bmp;base64," + base64(bytes),
    width: w * step,
    height: h * step,
  };
}

WorkerScript.onMessage = function (message) {
  const texture = render(message.width, message.height);
  WorkerScript.sendMessage({ key: message.key, texture: texture });
};
