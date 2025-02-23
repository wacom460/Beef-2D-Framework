using System;
using Bon;

namespace framework;

[BonTarget] class Timer {
	int64 ticks = at(0);
	public void set(float millis) => ticks = at(millis);
	int64 diff() => DateTime.Now.Ticks - ticks;
	int64 at(float millis) => { DateTime.Now.Ticks - (.)(millis * 10'000) };
	public this() {}
	public this(float millis = 0) => set(millis);
	public void zero() => ticks = DateTime.Now.Ticks;
	public float millis() => diff() / 10'000;
	public float seconds() => (.)diff() / 10'000'000;
	public bool once(float millis) => {
		var ret = false;
		if(millis() >= millis) {
			zero();
			ret = true;
		}
		ret
	};
}
