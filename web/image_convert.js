// All processing stays in the browser; input bytes are never uploaded.
(() => {
  const MAX_PIXELS = 16000000;
  const readData = file => new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = () => reject(new Error('无法读取文件，请重新选择。'));
    reader.readAsDataURL(file);
  });
  const load = url => new Promise((resolve, reject) => {
    const image = new Image();
    const timer = setTimeout(() => reject(new Error('图片解码超时。')), 15000);
    image.onload = () => { clearTimeout(timer); resolve(image); };
    image.onerror = () => { clearTimeout(timer); reject(new Error('图片损坏或浏览器不支持此格式。')); };
    image.src = url;
  });
  window.frequencyPickImage = () => new Promise(resolve => {
    const input = document.createElement('input');
    input.type = 'file'; input.accept = 'image/*';
    input.style.display = 'none'; document.body.appendChild(input);
    input.oncancel = () => { input.remove(); resolve(JSON.stringify({cancelled:true})); };
    input.onchange = async () => {
      try {
        const file = input.files?.[0];
        if (!file) { resolve(JSON.stringify({cancelled:true})); return; }
        if (file.size > 32 * 1024 * 1024) throw new Error('请选择小于 32 MB 的图片。');
        const data = await readData(file);
        const image = await load(data);
        if (!image.naturalWidth || image.naturalWidth * image.naturalHeight > MAX_PIXELS) throw new Error('原图超过 1600 万像素，请先缩小图片。');
        resolve(JSON.stringify({name:file.name, data, width:image.naturalWidth, height:image.naturalHeight, bytes:file.size}));
      } catch(error) { resolve(JSON.stringify({error:error.message})); }
      finally { input.remove(); }
    };
    input.click();
  });
  window.frequencyConvertImage = async request => {
    let canvas;
    try {
      const options = JSON.parse(request);
      const width = Number(options.width), height = Number(options.height);
      if (!Number.isInteger(width) || !Number.isInteger(height) || width < 1 || height < 1 || width > 8192 || height > 8192 || width*height > MAX_PIXELS) throw new Error('尺寸需为 1–8192 的整数，且总像素不超过 1600 万。');
      const format = options.format;
      if (!['png','jpeg','webp','ico'].includes(format)) throw new Error('不支持此输出格式。');
      if (format === 'ico' && (width !== height || ![16,32,48,64,128,256].includes(width))) throw new Error('ICO 必须为 16、32、48、64、128 或 256 像素正方形。');
      const image = await load(options.data);
      canvas = document.createElement('canvas'); canvas.width = width; canvas.height = height;
      const ctx = canvas.getContext('2d');
      if (!ctx) throw new Error('浏览器无法创建 Canvas。');
      if (format === 'jpeg') { ctx.fillStyle = /^#[a-fA-F0-9]{6}$/.test(options.background) ? options.background : '#ffffff'; ctx.fillRect(0,0,width,height); }
      ctx.drawImage(image,0,0,width,height);
      const mime = format === 'ico' ? 'image/png' : `image/${format}`;
      const blob = await new Promise(resolve => canvas.toBlob(resolve,mime,Math.min(1,Math.max(0.1,Number(options.quality)||0.92))));
      if (!blob || blob.type !== mime) throw new Error('此浏览器不支持所选编码格式，请选择 PNG。');
      const preview = await readData(blob);
      let output = blob;
      if (format === 'ico') {
        const png = new Uint8Array(await blob.arrayBuffer());
        const bytes = new Uint8Array(22+png.length), view = new DataView(bytes.buffer);
        view.setUint16(2,1,true); view.setUint16(4,1,true);
        bytes[6] = width === 256 ? 0 : width; bytes[7] = height === 256 ? 0 : height;
        view.setUint16(10,1,true); view.setUint16(12,32,true);
        view.setUint32(14,png.length,true); view.setUint32(18,22,true); bytes.set(png,22);
        output = new Blob([bytes],{type:'image/x-icon'});
      }
      const data = await readData(output);
      return JSON.stringify({data,preview,width,height,bytes:output.size,format,mime:output.type});
    } catch(error) { return JSON.stringify({error:error.message}); }
    finally { if (canvas) { canvas.width=0; canvas.height=0; } }
  };
  window.frequencyDownloadImage = request => {
    const options = JSON.parse(request);
    const [header,payload] = options.data.split(',');
    const raw = atob(payload), bytes = Uint8Array.from(raw,c=>c.charCodeAt(0));
    const blob = new Blob([bytes],{type:header.match(/data:([^;]+)/)?.[1]||'application/octet-stream'});
    const url = URL.createObjectURL(blob), anchor = document.createElement('a');
    anchor.href=url; anchor.download=options.name; anchor.click();
    setTimeout(()=>URL.revokeObjectURL(url),30000);
  };
})();
window.frequencyCreatePreview = id => {
  const frame = document.createElement('iframe');
  frame.id=id; frame.title='HTML 和 CSS 预览'; frame.setAttribute('sandbox','');
  frame.style.cssText='width:100%;height:100%;border:0;background:white;';
  return frame;
};
window.frequencyUpdatePreview = (frame, code) => {
  frame.srcdoc = `<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; img-src data: blob:; font-src data:;">${code}`;
};
