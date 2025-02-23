using SDL2;
using System.Collections;
using System.Diagnostics;
using System;
using System.IO;
using stb_truetype;
using static stb_truetype.stbtt;

namespace framework;

class TextureAtlas {
	public const var Size = 2048;
	public const char8 asciiStart = (.)32, asciiEnd = (.)126;
	public SDL.Surface *surf ~ SDL.FreeSurface(_);
	public SDL.Texture *tex ~ if(_ != null) SDL.DestroyTexture(_);
	SDL.Rect rect = .();
	append Dictionary<AssetType, SubTex> images;
	append List<SubTex> glyphs = .();
	Window w;

	public SubTex get(AssetType it) => images.ContainsKey(it) ? images[(.)it] : .(.Zero);

	public this(Window w) {
		this.w = w;
		tex = SDL.CreateTexture(w.renderer, SDL.PIXELFORMAT_RGBA8888, (.)SDL.TextureAccess.Target, Size, Size);
		SDL.SetTextureBlendMode(tex, .Blend);
		let fontData = Assets.Get(.fontTtf);
		generate(fontData);
	}

	public struct AtlasLoc
	{
		public const Self Zero = default;
		public const Self Whole = .(.(0,0), .(1,1));
		public SDL.FPoint topLeft = .(), bottomRight = .();
		public SDL.FPoint topRight => .(bottomRight.x, topLeft.y);
		public SDL.FPoint bottomLeft => .(topLeft.x, bottomRight.y);
		public Rect rectPixels;
		public Rect quad = .(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);
		public this(SDL.FPoint topLeft, SDL.FPoint bottomRight)
		{
			this.topLeft = topLeft;
			this.bottomRight = bottomRight;
			this.rectPixels = .Zero;
		}
	}

	public struct SubTex {
		public AtlasLoc loc;
		public SDL.FPoint size;
		public static operator AtlasLoc(ref Self s) => s.loc;
		public this(AtlasLoc loc, SDL.FPoint size = .())
		{
			this.loc = loc;
			this.size = size;
		}
	}
	
	public SubTex* this[char8 c]
		=> &glyphs[(char8)(c == '\n' ? ' ' :
			c < asciiStart || c >= asciiEnd ? '?' : c) - asciiStart];

	void generate(Span<uint8> fontData) {
		let fontSize = DrawList.TextSize.Large.ptsize;
		stbtt_fontinfo font;
		if (!stbtt_InitFont(&font, fontData.Ptr, stbtt_GetFontOffsetForIndex(fontData.Ptr, 0))) return;
		let brt = SDL.GetRenderTarget(w.renderer);
		SDL.SetRenderTarget(w.renderer, tex);
		SDL.SetTextureBlendMode(tex, .None);
		SDL.Color col = .(255, 255, 255, 255);

		float scale = 0;
		int32 glyphWidth = 0, glyphHeight = 0, glyphXOffset = 0, glyphYOffset = 0;
		uint8* glyphBitmap = null;
		SDL.Surface* RenderCharToSurface(stbtt_fontinfo* font, int32 charCode, int fontSize, SDL.Color col) {
		    scale = stbtt_ScaleForPixelHeight(font, fontSize);
		    glyphBitmap = stbtt_GetCodepointBitmap(font, 0, scale, charCode - 1,
				&glyphWidth, &glyphHeight, &glyphXOffset, &glyphYOffset);
		    if (glyphBitmap == null) return null;
		    defer stbtt_FreeBitmap(glyphBitmap, null);
		    let surface = SDL.CreateRGBSurfaceWithFormat(0, glyphWidth, glyphHeight, 32, SDL.PIXELFORMAT_ABGR8888);
		    if (surface == null) return null;
		    if(charCode != (.)' ' && charCode != (.)'\n') for (let y < glyphHeight)
				for (let x < glyphWidth)
					((uint32*)surface.pixels)[y * glyphWidth + x] =
						(uint32)glyphBitmap[y * glyphWidth + x] << 24 | (uint32)col.r << 16
							| (uint32)col.g << 8 | (uint32)col.b;
		    return surface;
		}

		for(char8 ic = asciiStart; ic <= asciiEnd; ++ic) {
			if(let ssurf = RenderCharToSurface(&font, (.)ic, fontSize, col)) {
				let stex = SDL.CreateTextureFromSurface(w.renderer, ssurf);
				SDL.SetTextureBlendMode(stex, .None);
				let gsz = Vec2(ssurf.w, ssurf.h);
				defer SDL.FreeSurface(ssurf);
				defer SDL.DestroyTexture(stex);
				if(rect.y + gsz.y >= Size) break;
				if(rect.x + gsz.x >= Size) {
					rect.y += (.)fontSize + 5;
					rect.x = 0;
				}
				float yoff = fontSize + glyphYOffset - 3;
				SDL.Rect src = .(0, 0, (.)gsz.x, (.)gsz.y),
						 dst = .(rect.x, rect.y + (.)yoff, (.)gsz.x, (.)gsz.y);
				SDL.RenderCopy(w.renderer, stex, &src, &dst);
				let left = (float)dst.x / (float)Size;
				let top = (float)rect.y / (float)Size;
				let w = (float)gsz.x / (float)Size;
				let h = (float)(fontSize + 2) / (float)Size;
				AtlasLoc aloc = .(.(left, top), .(left + w, top + h));
				aloc.rectPixels = .(dst.x, rect.y, gsz.x, fontSize + 2);
				glyphs.Add(.(aloc, .(gsz.x, fontSize)));
				rect.x += (.)gsz.x + 10;
			}
		}

		rect.y += fontSize + 15;
		rect.x = 0;

		void addImage(Span<uint8> img, AssetType type) {
			Img i = scope .(w, img.Ptr, (.)img.Length);
			SDL.SetTextureBlendMode(i.texture, .None);
			let gsz = Vec2(i.surface.w, i.surface.h);
			if(rect.y + gsz.y >= Size) {
				Debug.Break();
				return;
			}
			if(rect.x + gsz.x >= Size) {
				rect.y += (.)gsz.y + 5;
				rect.x = 0;
			}
			SDL.Rect src = .(0, 0, (.)gsz.x, (.)gsz.y),
					 dst = .(rect.x, rect.y, (.)gsz.x, (.)gsz.y);
			SDL.RenderCopy(w.renderer, i.texture, &src, &dst);
			let left = (float)rect.x / (float)Size;
			let top = (float)rect.y / (float)Size;
			let w = (float)gsz.x / (float)Size;
			let h = (float)gsz.y / (float)Size;
			AtlasLoc aloc = .(.(left, top), .(left + w, top + h));
			aloc.rectPixels = .(rect.x, rect.y, gsz.x, gsz.y);
			images.Add(type, .(aloc));
			rect.x += (.)gsz.x + 5;
		}

		for(let a in Asset.GetAllOfExt(.Png)) addImage(Assets.Get(a), a);

		SDL.SetRenderDrawColor(w.renderer, 255, 255, 255, 255);
		SDL.Rect tltR = .(0, 0, 1, 1);
		SDL.RenderFillRect(w.renderer, &tltR);
		SDL.SetTextureBlendMode(tex, .Blend);
		SDL.SetRenderTarget(w.renderer, brt);
	}
}
