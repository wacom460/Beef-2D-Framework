using SDL2;
using System;
using System.IO;
using System.Collections;
using stb_image;
using System.Diagnostics;

namespace framework;

class Img {
	public Window w;
	public SDL.Surface* surface ~ if(_ != null) SDL.FreeSurface(_);
	public SDL.Texture* texture ~ if(_ != null) SDL.DestroyTexture(_);

	public bool Valid => surface != null && texture != null;
	public Vec2 Size => .(surface.w, surface.h);

	public static (SDL.Surface*, SDL.Texture*, void* idata) LoadImage(Window w, void *pngData, int32 dataLen)
	{
		SDL.Surface* surface = null;
		SDL.Texture* texture = null;
		int32 width = 0, height = 0, bpp = 0;
		let idata = stbi.stbi_load_from_memory((.)pngData, dataLen, &width, &height, &bpp, 0);
		var pitch = width * bpp;
		pitch = (pitch + 3) & ~3;
		surface = SDL.CreateRGBSurfaceFrom(idata, width, height, bpp*8, pitch, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000);
		/*if(surface == null) Debug.WriteLine(scope String(SDL.GetError()));
		Debug.Assert(surface != null);*/
		if(surface != null) {
			texture = SDL.CreateTextureFromSurface(w.renderer, surface);
			Debug.Assert(texture != null);
			SDL.SetTextureBlendMode(texture, .Blend);
			return (surface, texture, idata);
		}
		if(idata != null)
			Internal.Free(idata);
		return (null, null, null);
	}

	public this(Window w, void *pngData, int32 dataLen, bool freeIData = true) {
		this.w = w;
		void* idata;
		(surface, texture, idata) = LoadImage(w, pngData, dataLen);
		if(freeIData && idata != null) Internal.Free(idata);
	}

	public this(Window w, String path) {
		this.w = w;
		void* idata;
		List<uint8> pngData = scope .();
		if(File.ReadAll(path, pngData) case .Ok) {
			(surface, texture, idata) = LoadImage(w, pngData.Ptr, (.)pngData.Count);
		}
	}
}