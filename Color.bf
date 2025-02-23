using SDL2;
using System;
using Bon;

namespace framework;

[BonTarget] struct Color {

	public const Color White = .(255, 255, 255);
	public const Color Gray = .(100, 100, 100);
	public const Color Black = .(0, 0, 0);
	public const Color Yellow = .(255, 255, 0);
	public const Color Red = .(255, 0, 0);
	public const Color Green = .(0, 255, 0);
	public const Color Blue = .(0, 0, 255);
	public const Color Brown = .(165, 42, 42);
	public const Color Cyan = .(0, 255, 255);
	public const Color Pink = .(255, 192, 203);
	public const Color Transparent = .(0, 0, 0, 0);
	public const Color Disabled = .(10, 10, 10, 160);

	public int r, g, b, a;

	public this(int r, int g, int b, int a = 255) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public this(Color col, uint8 a) {
		this.r = col.r;
		this.g = col.g;
		this.b = col.b;
		this.a = a;
	}

	public static Self operator*(Self lhs, Self rhs)
		=> .(lhs.r * (rhs.r / 255), lhs.g * (rhs.g / 255), lhs.b * (rhs.b / 255), lhs.a * (rhs.a / 255));

	public static Self operator*(Self lhs, float x)
		=> .((.)((.)lhs.r * x), (.)((.)lhs.g * x), (.)((.)lhs.b * x));

	public static operator SDL.Color(Color c)
		=> .((.)c.r, (.)c.g, (.)c.b, (.)c.a);

	public static operator Self(uint32 pixel) {
		uint8 r = (.)(pixel & 0xFF);
		uint8 g = (.)((pixel >> 8) & 0xFF);
		uint8 b = (.)((pixel >> 16) & 0xFF);
		uint8 a = (.)((pixel >> 24) & 0xFF);
		return .(r, g, b, a);
	}

	public Color changeBrightness(float amount)
		=> this * .((.)((float)r * amount), (.)((float)g * amount), (.)((float)b * amount), (.)((float)a * amount));

	public Color modAlpha(uint8 alpha) => .(r, g, b, alpha);

	public override void ToString(String strBuffer) {
		strBuffer.Append(scope $"r: {r} g: {g} b: {b} a: {a}");
	}
}
