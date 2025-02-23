using SDL2;
using System;
using Bon;

namespace framework;

[BonTarget] struct Rect {
	public const Self Zero = .(0, 0, 0, 0);

	public Vec2 pos, size;
	public float X {
		get => pos.x;
		set mut {
			pos.x = value;
		}
	};
	public float Y {
		get => pos.y;
		set mut {
			pos.y = value;
		}
	};
	public float Width {
	  	get => size.x;
		set mut {
			size.x = value;
		}
	};
	public float WidthQ => size.x - pos.x;
	public float HeightQ => size.y - pos.y;
	public float WidthDiv2 => Width / 2;
	public float Height {
		get => size.y;
		set mut {
			size.y = value;
		}
	};
	public float HeightDiv2 => Height / 2;

	public float Right => pos.x + size.x;
	public float Bottom => pos.y + size.y;
	public Vec2 TopLeft => .(pos.x, pos.y);
	public Vec2 TopRight => .(Right, pos.y);
	public Vec2 TopRightQ => .(size.x, pos.y);
	public Vec2 BottomLeft => .(pos.x, Bottom);
	public Vec2 BottomLeftQ => .(pos.x, size.y);
	public Vec2 BottomRight => .(Right, Bottom);
	public Vec2 BottomRightQ => .(size.x, size.y);
	public Vec2 Div2 => .(size.x / 2, size.y / 2);
	public Vec2 Center => Div2;
	public Rect Quad => .(pos.x, pos.y, pos.x + size.x, pos.y + size.y);
	public Rect Box => .(pos.x, pos.y, size.x - pos.x, size.y - pos.y);
	public Vec2 Pos => .(pos.x, pos.y);
	public Vec2 Size => .(size.x, size.y);

	public static operator Rect(Vec2 v) => .(width: v.x, height: v.y);
	public static operator SDL.Rect(Rect rect) => .((.)rect.pos.x, (.)rect.pos.y, (.)rect.size.x, (.)rect.size.y);

	public this(float left = 0, float top = 0, float width = 0, float height = 0)
	{
		this.pos = .(left, top);
		this.size = .(width, height);
	}

	public bool boxContains(Vec2 point) => point.x >= pos.x && point.x < pos.x + size.x && point.y >= pos.y && point.y < pos.y + size.y;
	
	public bool quadContains(Vec2 point) => point.x >= pos.x && point.x < size.x && point.y >= pos.y && point.y < size.y;

	public Rect limitedBox(Rect fr)
	{
		float l = pos.x, t = pos.y, r = pos.x + size.x, b = pos.y + size.y;
		float pl = fr.pos.x, pt = fr.pos.y, pr = fr.pos.x + fr.size.x, pb = fr.pos.y + fr.size.y;
		l = Math.Clamp(l, pl, pr);
		r = Math.Clamp(r, pl, pr);
		t = Math.Clamp(t, pt, pb);
		b = Math.Clamp(b, pt, pb);
		return .(l, t, r - l, b - t);
	}

	public Rect limitedQuad(Rect fr)
	{
		float l = pos.x, t = pos.y, r = size.x, b = size.y;
		float pl = fr.pos.x, pt = fr.pos.y, pr = fr.size.x, pb = fr.size.y;
		l = Math.Clamp(l, pl, pr);
		r = Math.Clamp(r, pl, pr);
		t = Math.Clamp(t, pt, pb);
		b = Math.Clamp(b, pt, pb);
		return .(l, t, r, b);
	}

	public Rect limitToBox(Rect fr) mut
	{
		this = limitedBox(fr);
		return this;
	}

	public Rect limitToQuad(Rect fr) mut
	{
		this = limitedQuad(fr);
		return this;
	}

	public override void ToString(String strBuffer) => strBuffer.Append(scope $"l:{pos.x},t:{pos.y},w:{size.x}h:{size.y}");
}
