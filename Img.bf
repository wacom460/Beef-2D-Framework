using SDL2;
using System;
using System.IO;
using System.Collections;

namespace framework;

class Img {
	public Window w;
	public SDL.Surface* surface ~ if(_ != null) SDL.FreeSurface(_);
	public SDL.Texture* texture ~ if(_ != null) SDL.DestroyTexture(_);

	public Vec2 Size => .(surface.w, surface.h);

	public this(Window w, void *pngData, int32 dataLen, bool freeIData = true) {
		this.w = w;
		void* idata;
		(surface, texture, idata) = Util.LoadImage(w, pngData, dataLen);
		if(freeIData && idata != null) Internal.Free(idata);
	}

	public this(Window w, String path) {
		this.w = w;
		void* idata;
		List<uint8> pngData = scope .();
		if(File.ReadAll(path, pngData) case .Ok) {
			(surface, texture, idata) = Util.LoadImage(w, pngData.Ptr, (.)pngData.Count);
		}
	}
}