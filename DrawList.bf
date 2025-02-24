using System;
using SDL2;
using System.Collections;
using System.Diagnostics;

namespace framework;

[Optimize] class DrawList {
	public static bool DisableScissor = false;
	public append List<Tri> tris;
	public Window hostWindow;
	public append List<Rect> scissorStack;
	public Rect ScissorRect {
		get {
			Rect ret = scissorStack.IsEmpty ? .Zero : scissorStack.Back;
			let fudge = 1f;
			if(ret != .Zero){
				ret.pos.x -= fudge;
				ret.size.x += fudge*2;
				ret.pos.y -= fudge;
				ret.size.y += fudge*2;
			}
			return ret;
		}
	}
	
	[Inline] public ref Tri this[int idx] => {
		if(idx >= tris.Count) tris.EnsureCapacity(idx + 1, false);
		ref tris[idx]
	};

	public this(Window w) {
		this.hostWindow = w;
	}

	public void moveAll(Vec2 amount) {
		for(let t in ref tris) for(var v in ref t.verts) v.position += amount;
	}

	public struct Tri {
		public SDL.Vertex[3] verts;

		public this(SDL.Vertex v1, SDL.Vertex v2, SDL.Vertex v3) {
			verts = .(v1, v2, v3);
		}

		public ref SDL.Vertex this[int idx] mut => ref verts[idx];
	}

	public const var TextColorChar = '~';
	public const uint32 MaxLines = 1024;

	public enum Justification
	{
		Left,
		Center,
		Right
	}

	public enum Origin
	{
		Left,
		Right,
		Center,
		Top,
		Bottom
	}

	public enum TextSize
	{
		case Custom(int ptSize);
		case Large;
		case Medium;
		case Small;
		case Tiny;

		public int32 ptsize
		{
			get
			{
				switch(this)
				{
				case Custom(let ptSize): return (.)ptSize;
				case Large: return 55;
				case Medium: return 45;
				case Small: return 35;
				case Tiny: return 25;
				}
			}
		}

		public float Scale => (float)ptsize / (float)Large.ptsize;
	}

	public const var White = 'w';
	public const var Gray = 'h';
	public const var Black = '0';
	public const var Yellow = 'u';
	public const var Green = 'a';
	public const var Red = 'r';
	public const var Brown = 'p';
	public const var Cyan = 'c';
	public const var Pink = 'z';
	public const var Transparent = 't';
	public const var Disabled = 'd';

	public static float[MaxLines] lineWidths;

	public static Color getColorFromChar(char8 c)
	{
		if(c == White) return .White;
		if(c == Gray) return .Gray;
		if(c == Black) return .Black;
		if(c == Yellow) return .Yellow;
		if(c == Green) return .Green;
		if(c == Red) return .Red;
		if(c == Brown) return .Brown;
		if(c == Cyan) return .Cyan;
		if(c == Pink) return .Pink;
		if(c == Transparent) return .Transparent;
		if(c == Disabled) return .Disabled;
		return .White;
	}

	public Rect drawText(TextSize size, String str, float x, float y, float widthLimit, float widthCutoff, uint8 opacity, Origin ox, Origin oy,
		Justification just, int cursorLineIndex = -1)
	{
		var widthLimit, cursorLineIndex;
		let ogCLI = cursorLineIndex;
		if(widthLimit == 0) widthLimit = Int32.MaxValue;

		var strLen = str.Length;
		Rect draw(float x, float y, bool colorOverrideOn, Color colorOverride) {
			cursorLineIndex = ogCLI;
			float msy = 0, sx = 0, sy = 0, atx = 0, aty = 0;
			int lineCount = 0, lineIndex = 0;
			for(var i < strLen)
			{
				let cc = str[i];
				if(cc == TextColorChar)
				{
					++i;
					continue;
				}

				let gr = drawChar(size, .(), .Transparent, cc);
				let gw = gr.size.x, gh = gr.size.y;
				if(gh > msy) msy = gh;
				sx += gw;
				if(sx > atx) atx = sx;
				if(sy + gh > aty) aty = sy + gh;
				if(sx + gw > widthLimit || cc == '\n' || i == strLen - 1)
				{
					if(lineIndex < MaxLines) lineWidths[lineIndex] = sx;
#if DEBUG						
					else Debug.WriteLine("Warning: Text render exceeded maximum amount of lines.");
#endif
					sx = 0;
					sy += msy;
					lineCount++;
					lineIndex++;
				}
			}

			Color ccol = colorOverrideOn ? colorOverride : .White;
			float orx = 0, ory = 0;

			switch(ox)
			{
			case .Left:
				orx = x;
			case .Right:
				orx = x - atx;
			case .Center:
				orx = x - (atx / 2);
			default:
			}

			switch(oy)
			{
			case .Top:
				ory = y;
			case .Bottom:
				ory = y - aty;
			case .Center:
				ory = y - (aty / 2);
			default:
			}

			mixin orxp(int ln)
			{
				(lineCount > 1 ? (just == .Center ? ((atx / 2) - (lineWidths[ln] / 2)) : (just == .Right ? (atx - lineWidths[ln]) : 0)) : 0)
			}

			float rx = orx + orxp!(0), ry = ory;
			Rect trect = .(orx, ory, atx, aty);

			if(opacity > 0)
			{
				float maxhei = 0;
				lineIndex = 0;
				for(var i < strLen)
				{
					let cc = str[i];
					if(cc == TextColorChar && i + 1 < strLen)
					{
						char8 ccn = str[i + 1];
						if(!colorOverrideOn) ccol = getColorFromChar(ccn);
						i++;
						cursorLineIndex += 2;
						continue;
					}
					let gr = drawChar(size, .(), .Transparent, cc);
					let gw = gr.size.x, gh = gr.size.y;
					let end = cursorLineIndex >= str.Length;
					let two = (end && i + 1 >= str.Length);
					if(cursorLineIndex == i || two) {
						if(two) rx += gw;
						line(.(rx, ry), .(rx, ry + gh), .Black, 2);
						if(two) rx -= gw;
					}
					if(rx - orx < widthCutoff || widthCutoff == 0) {
						drawChar(size, .(rx, ry), ccol.modAlpha(opacity), cc);
					}
					rx += gw;
					if(gh > maxhei) maxhei = gh;
					if(rx - orx + gw > widthLimit || cc == '\n')
					{
						lineIndex++;
						rx = orx + orxp!(lineIndex);
						ry += maxhei;
					}
				}
			}

			return trect;
		}

		let border = 1.12f;
		let borderCol = Color.Black;
		draw(x - border, y - border, true, borderCol);
		draw(x, y - border, true, borderCol);
		draw(x + border, y - border, true, borderCol);
		draw(x + border, y, true, borderCol);
		draw(x + border, y + border, true, borderCol);
		draw(x, y + border, true, borderCol);
		draw(x - border, y + border, true, borderCol);
		draw(x - border, y, true, borderCol);

		return draw(x, y, false, .White);
	}
	
	[Inline]
	public void pushScissor(Rect fr, bool bypassParentLimit = false) {
		let allow = fr.size.x > 0 && fr.size.y > 0;
		var fr;
		if(allow && scissorStack.Count > 0 && !bypassParentLimit) fr.limitToBox(scissorStack.Back);
		scissorStack.Add(fr);
	}
	
	[Inline]
	public void popScissor() {
		if(!scissorStack.IsEmpty) scissorStack.PopBack();
	}
	
	[Inline]
	public ref Tri add(Tri t) {
		tris.Add(t);
		return ref tris.Back;
	}

	public void addMulti(params Span<Tri> ts) {
		for(let t in ts) add(t);
	}

	public void addMulti2(Span<Tri> ts) {
		for(let t in ts) add(t);
	}

	public void add(DrawList dl) {
		tris.AddRange(dl.tris);
		scissorStack.AddRange(dl.scissorStack);
	}
	
	[Inline]
	public void clear() {
		tris.Clear();
	}

	[Inline]
	public Vec2 getIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
	    Vec2 intersection;
	    
	    float ua = ((x4 - x3)*(y1 - y3) - (y4 - y3)*(x1 - x3)) / ((y4 - y3)*(x2 - x1) - (x4 - x3)*(y2 - y1));
	    float ub = ((x2 - x1)*(y1 - y3) - (y2 - y1)*(x1 - x3)) / ((y4 - y3)*(x2 - x1) - (x4 - x3)*(y2 - y1));
	    
	    if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) {
	        intersection.x = x1 + ua * (x2 - x1);
	        intersection.y = y1 + ua * (y2 - y1);
	    } else {
	        intersection.x = float.NaN;
	        intersection.y = float.NaN;
	    }

	    return intersection;
	}

	[Inline]
	public void render(SDL.Texture* tex) {
		if(tris.IsEmpty) return;
		SDL.RenderGeometry(hostWindow.renderer, tex, (.)tris.Ptr, (.)(tris.Count * 3), null, 0);
	}

	[Inline]
	private Rect drawChar(TextSize size, Vec2 pos, Color col, char8 c, bool italics = false) {
		if(c == '\n') return .Zero;
		let al = hostWindow.atlas[c];
		let rect = Rect(pos.x, pos.y, al.size.x * size.Scale, al.size.y * size.Scale);
		if(c != ' ') fillBox(rect, col, al.loc);
		return rect;
	}

	[Inline]
	public void tri(Tri t, Color col = .Yellow, float thickness = 1f) {
		line(t.verts[0].position, t.verts[1].position, col, thickness, true);
		line(t.verts[0].position, t.verts[2].position, col, thickness, true);
		line(t.verts[2].position, t.verts[1].position, col, thickness, true);
	}

	[Inline]
	public void tri(Tri t, Color c1 = .Red, Color c2 = .Green, Color c3 = .Blue, float thickness = 1f) {
		line(t.verts[0].position, t.verts[1].position, c1, thickness, true);
		line(t.verts[0].position, t.verts[2].position, c2, thickness, true);
		line(t.verts[2].position, t.verts[1].position, c3, thickness, true);
	}

	[Inline]
	public void line(Vec2 p1, Vec2 p2, Color col = .White, float thickness = 1f, bool noScissor = false) {
		var p1, p2, noScissor;
		if(DisableScissor) noScissor = true;
		var thickness;
		p1.x += 0.5f;
		p1.y += 0.5f;
		p1.Round();
		p2.x += 0.5f;
		p2.y += 0.5f;
		p2.Round();
		if(thickness < 1) thickness = 1;
		let sr = ScissorRect;
		if(sr != .Zero && !noScissor)
		{
			if(p1.x < p2.x){
				if(p1.x < sr.pos.x) {
					p1 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.pos.x, sr.pos.y, sr.pos.x, sr.Bottom);
				}
				if(p2.x > sr.Right) {
					p2 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.Right, sr.pos.y, sr.Right, sr.Bottom);
				}
			} else if(p2.x <= p1.x){
				if(p2.x < sr.pos.x) {
					p2 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.pos.x, sr.pos.y, sr.pos.x, sr.Bottom);
				}
				if(p1.x > sr.Right) {
					p1 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.Right, sr.pos.y, sr.Right, sr.Bottom);
				}
			}
			if(p1.y < p2.y){
				if(p1.y < sr.pos.y) {
					p1 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.pos.x, sr.pos.y, sr.Right, sr.pos.y);
				}
				if(p2.y > sr.Bottom) {
					p2 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.pos.x, sr.Bottom, sr.Right, sr.Bottom);
				}
			} else if(p2.y <= p1.y){
				if(p2.y < sr.pos.y) {
					p2 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.pos.x, sr.pos.y, sr.Right, sr.pos.y);
				}
				if(p1.y > sr.Bottom) {
					p1 = getIntersection(p1.x, p1.y, p2.x, p2.y, sr.pos.x, sr.Bottom, sr.Right, sr.Bottom);
				}
			}
		}
		float px = -(p2.y - p1.y), py = p2.x - p1.x;
		let length = Math.Sqrt(px * px + py * py);
		px /= length;
		py /= length;

		let halfThickness = thickness / 2;

		let x12 = p1.x - halfThickness * px;
		let y12 = p1.y - halfThickness * py;

		let x21 = p2.x + halfThickness * px;
		let y21 = p2.y + halfThickness * py;

		let x22 = p2.x - halfThickness * px;
		let y22 = p2.y - halfThickness * py;

		addMulti(
			.(
			  .(.(p1.x + halfThickness * px, p1.y + halfThickness * py), col),
			  .(.(x12, y12), col),
			  .(.(x21, y21), col)
			 ),
			.(
			  .(.(x21, y21), col),
			  .(.(x22, y22), col),
			  .(.(x12, y12), col)
			 )
		);
	}
	
	[Inline]
	public void lineQuad(Rect quad, Color col = .White, float thickness = 1f)
	{
		line(quad.TopLeft, quad.TopRightQ, col, thickness);
		line(quad.TopRightQ, quad.BottomRightQ, col, thickness);
		line(quad.BottomRightQ, quad.BottomLeftQ, col, thickness);
		line(quad.BottomLeftQ, quad.TopLeft, col, thickness);
	}
	
	[Inline]
	public void fillQuad(Rect quad, Color c1 = .White, Color c2 = .White, Color c3 = .White, Color c4 = .White, TextureAtlas.AtlasLoc al = .Zero)
	{
		var quad;
		let sr = ScissorRect;
		if(sr != .Zero) quad.limitToQuad(sr.Quad);
		addMulti(
			.(
			  .(quad.TopLeft, c1, al.topLeft),
			  .(quad.TopRightQ, c2, al.topRight),
			  .(quad.BottomRightQ, c3, al.bottomRight)
			 ),
			.(
			  .(quad.TopLeft, c1, al.topLeft),
			  .(quad.BottomLeftQ, c4, al.bottomLeft),
			  .(quad.BottomRightQ, c3, al.bottomRight)
			 )
		);
	}
	
	[Inline]
	public void fillQuad(Rect quad, Color col = .White, TextureAtlas.AtlasLoc al = .Zero) {
		var quad;
		let sr = ScissorRect;
		if(sr != .Zero) quad.limitToQuad(sr.Quad);
		addMulti(
			.(
			  .(quad.TopLeft, col, al.topLeft),
			  .(quad.TopRightQ, col, al.topRight),
			  .(quad.BottomRightQ, col, al.bottomRight)
			 ),
			.(
			  .(quad.TopLeft, col, al.topLeft),
			  .(quad.BottomLeftQ, col, al.bottomLeft),
			  .(quad.BottomRightQ, col, al.bottomRight)
			 )
		);
	}
	
	[Inline]
	public void lineBox(Rect rect, Color col = .White, float thickness = 1f, bool noScissor = false) {
		var rect;
		let sr = ScissorRect;
		if(sr != .Zero && !noScissor) rect.limitToBox(sr);
		line(rect.TopLeft, rect.TopRight, col, thickness);
		line(rect.TopRight, rect.BottomRight, col, thickness);
		line(rect.BottomRight, rect.BottomLeft, col, thickness);
		line(rect.BottomLeft, rect.TopLeft, col, thickness);
	}

	[Inline]
	public Rect drawSheetTile(AssetType asset, uint sheetWidth, uint sheetHeight, uint tileIndex, Vec2 pos, Vec2 origin = .Zero, Vec2 scale = .One, Color col = .White)
		=> drawSheetTile(hostWindow.atlas.get(asset), sheetWidth, sheetHeight, tileIndex, pos, origin, scale, col);

	[Inline]
	public Rect drawSheetTile(TextureAtlas.AtlasLoc sheetLoc, uint sheetWidth, uint sheetHeight, uint tileIndex, Vec2 pos, Vec2 origin = .Zero, Vec2 scale = .One, Color col = .White) {
		var tileIndex;
		if(tileIndex >= sheetWidth * sheetHeight)
			tileIndex = (sheetWidth * sheetHeight) - 1;
		let rp = sheetLoc.rectPixels, q = sheetLoc.quad,
			tileSzPx = Vec2(rp.size.x / sheetWidth, rp.size.y / sheetHeight),
			tileSzQ = Vec2(q.WidthQ / sheetWidth, q.HeightQ / sheetHeight),
			sz = Rect(pos.x - (tileSzPx.x * origin.x * scale.y), pos.y - (tileSzPx.y * origin.y * scale.y), tileSzPx.x * scale.x, tileSzPx.y * scale.y),
			apos = Vec2(sheetLoc.topLeft.x + ((tileIndex % sheetWidth) * tileSzQ.x),
				sheetLoc.topLeft.y + ((tileIndex / sheetWidth) * tileSzQ.y));
		fillBox(sz, col, .(apos, apos + tileSzQ));
		return sz;
	}
	
	[Inline]
	public void fillBox(Rect rect, Color col = .White, TextureAtlas.AtlasLoc al = .Zero)
	{
		var rect;
		if(col.a ==0 )return;
		let sr = ScissorRect;
		if(sr != .Zero) rect.limitToBox(sr);
		addMulti(
			.(
			  .(rect.TopLeft, col, al.topLeft),
			  .(rect.TopRight, col, al.topRight),
			  .(rect.BottomRight, col, al.bottomRight)
			 ),
			.(
			  .(rect.TopLeft, col, al.topLeft),
			  .(rect.BottomLeft, col, al.bottomLeft),
			  .(rect.BottomRight, col, al.bottomRight)
			 )
		);
	}
}
