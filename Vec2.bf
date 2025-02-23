using System;
using SDL2;
using Bon;

namespace framework;

[BonTarget] struct Vec2 {

	public const Vec2 Zero = .(0, 0);
	public const Vec2 One = .(1, 1);

	public float x;
	public float y;

	public this(float x = 0, float y = 0)
	{
		this.x = x;
		this.y = y;
	}

	public float angle(Vec2 to) => Math.Atan2(y - to.y, x - to.x);

	public Vec2 HorizOnly => .(x, 0);
	public Vec2 VertiOnly => .(0, y);

	public static Vec2 RotateAroundOrigin(Vec2 p, float radians, Vec2 origin)
	{
		var p;

		let s = Math.Sin(radians);
		let c = Math.Cos(radians);
		
		p -= origin;
		
		let xn = p.x * c - p.y * s;
		let yn = p.x * s + p.y * c;
		
		p.x = (.)xn + origin.x;
		p.y = (.)yn + origin.y;
		
		return p;
	}

	public void Round() mut {
		/*x = (.)(int32)x;
		y = (.)(int32)y;*/
		x = Math.Round(x);
		y = Math.Round(y);
	}

	public Vec2 Deadzoned(int amt)
	{
		Vec2 ret = this;
		if(Math.Abs(ret.x) < amt) ret.x = 0;
		if(Math.Abs(ret.y) < amt) ret.y = 0;
		return ret;

	}

	public void deadzone(int amt) mut => this = Deadzoned(amt);

	public void clampL(Vec2 b) mut
	{
		if(x < b.x) x = b.x;
		if(y < b.y) y = b.y;
	}
	
	public int Length => (.)Math.Sqrt(x * x + y * y);
	public static Vec2 operator+(Vec2 lhs, Vec2 rhs) => .(lhs.x + rhs.x, lhs.y + rhs.y);
	public static Vec2 operator-(Vec2 lhs, Vec2 rhs) => .(lhs.x - rhs.x, lhs.y - rhs.y);
	public static Vec2 operator/(Vec2 lhs, int rhs) => .(lhs.x / rhs, lhs.y / rhs);
	public static operator Vec2(SDL.FPoint fp) => .((.)fp.x, (.)fp.y);
	public static operator Vec2(SDL.Point p) => .((.)p.x, (.)p.y);
	public static operator SDL.FPoint(Vec2 v) => .(v.x, v.y);

	public static int Dist(Vec2 p1, Vec2 p2)
	{
		let nmx = (p1.x - p2.x), nmy = (p1.y - p2.y);
		return (.)Math.Abs(Math.Sqrt((nmx * nmx) + (nmy * nmy)));
	}

	public static int DistToLine(Vec2 p, Vec2 p1, Vec2 p2)
	{
		float A = p.x - p1.x; // position of point rel one end of line
		float B = p.y - p1.y;
		float C = p2.x - p1.x; // vector along line
		float D = p2.y - p1.y;
		float E = -D; // orthogonal vector
		float F = C;

		float dot = A * E + B * F;
		float len_sq = E * E + F * F;

		return (.)(Math.Abs(dot) / Math.Sqrt(len_sq));
	}

	public override void ToString(String strBuffer) => strBuffer.Append(scope $"x: {x} y: {y}");
}
