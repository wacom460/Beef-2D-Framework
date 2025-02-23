using System.Diagnostics;
using System.Collections;
using System;
using Bon;

namespace framework;

[BonTarget] public class Animation {
	public struct Keyframe : this(float time, Vec2 pos = .Zero, Color col = .White, Rect rect = .Zero, Ease easing = .None) {
		public Keyframe *next = null;
	}
	
	[BonTarget] public enum State {
		Paused,
		Forward,
		Reverse,
		Done
	}

	public float time, length;
	public bool loop, pingPong;
	public State state;
	public append Stopwatch clock = .();
	public append List<Keyframe> frames = .();

	public ref Keyframe this[int idx] => ref frames[idx];
	
	public this(float length, float time = 0, bool loop = false, bool pingPong = false) {
		this.length = length;
		this.time = time;
		this.loop = loop;
		this.pingPong = pingPong;
	}

	public Self add(params Span<Keyframe> keyframes) {
		for(let kf in keyframes) {
			Keyframe* last = null;
			if(!frames.IsEmpty) last = &frames.Back;
			frames.Add(kf);
			if(last != null) last.next = &frames.Back;
		}
		return this;
	}

	public Keyframe interpolate() {
		Keyframe ret = .(0);
		for (let kf in frames) {
			if(kf.time >= time) break;
			ret = kf;
		}
		if (ret.next != null) {
			let ckf = ret;
			let ms = (float)Easing.Apply(ckf.easing, time, 0, length, length);
			let nkf = ckf.next;
			let ckfT = ckf.time;
			let nkfT = ckf.next.time;
			Debug.Assert(ckfT <= nkfT);
			ret.pos.x = (.)Util.Scale(ms, ckfT, nkfT, ckf.pos.x, nkf.pos.x);
			ret.pos.y = (.)Util.Scale(ms, ckfT, nkfT, ckf.pos.y, nkf.pos.y);
			ret.col.r = (.)Util.Scale(ms, ckfT, nkfT, ckf.col.r, nkf.col.r);
			ret.col.g = (.)Util.Scale(ms, ckfT, nkfT, ckf.col.g, nkf.col.g);
			ret.col.b = (.)Util.Scale(ms, ckfT, nkfT, ckf.col.b, nkf.col.b);
			ret.col.a = (.)Util.Scale(ms, ckfT, nkfT, ckf.col.a, nkf.col.a);
			ret.rect.pos.x = (.)Util.Scale(ms, ckfT, nkfT, ckf.rect.pos.x, nkf.rect.pos.x);
			ret.rect.pos.y = (.)Util.Scale(ms, ckfT, nkfT, ckf.rect.pos.y, nkf.rect.pos.y);
			ret.rect.size.x = (.)Util.Scale(ms, ckfT, nkfT, ckf.rect.size.x, nkf.rect.size.x);
			ret.rect.size.y = (.)Util.Scale(ms, ckfT, nkfT, ckf.rect.size.y, nkf.rect.size.y);
		}
		return ret;
	}

	public bool update() {
		if(state != .Forward && state != .Reverse) return false;

		float ms = clock.ElapsedMicroseconds / 1000.0f;
		clock.Restart();

		switch(state) {
		case .Forward:
			if(time + ms >= length) restart();
			else time += ms;
		case .Reverse:
			if(time - ms <= 0) restart();
			else time -= ms;
		default:
		}

		return true;
	}

	public void reset() {
		state = .Forward;
		time = 0;
		clock.Restart();
	}
	
	void restart() {
		if(loop) {
			if(pingPong) {
				if(state == .Reverse) start();
				else reverse();
			} else {
				switch(state) {
				case .Forward:
					time = 0;
				case .Reverse:
					time = length;
				default:
				}
			}
		}
		else stop();
	}

	public void pause() => state = .Paused;
	public void start() => state = .Forward;
	public void reverse() => state = .Reverse;
	public void stop() {
		state = .Done;
		time = length;
	}
}
