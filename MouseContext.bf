using System;
using SDL2;

namespace framework;

struct MouseContext {
	public Vec2 pos, relPos, posOnClick, moveDelta, scrollDelta;
	public int travelDist;
	public bool ButtonFF, ButtonDown, ButtonReleased;
	public bool LeftDouble;
	public bool LeftFF, MiddleFF, RightFF; /* first frame */
	public bool leftDown, middleDown, rightDown;
	public bool leftRel, middleRel, rightRel;
	public float? ScrolledY => scrollDelta.y != 0 ? scrollDelta.y : null;
	public bool leftFFD => leftDown && (Moving || LeftFF);
	public bool PosEqPOC => pos == posOnClick;
	public bool PosEqPOR => pos == relPos;
	public Vec2 DragDelta => .(pos.x - posOnClick.x, pos.y - posOnClick.y);
	public Vec2 DragDeltaAbs => .(Math.Abs(pos.x - posOnClick.x), Math.Abs(pos.y - posOnClick.y));
	public Vec2 MoveDeltaAbs => .(Math.Abs(moveDelta.x), Math.Abs(moveDelta.y));
	public bool WasMoved => pos != posOnClick;
	public bool Moving => moveDelta.Length > 0;
	public bool StateChanged => ButtonFF || ButtonReleased || moveDelta != .Zero || scrollDelta != .Zero;

	public bool WasMovedDist(float d) => Vec2.Dist(pos, posOnClick) >= d;

	public void unDown() mut
	{
		leftDown = false;
		middleDown = false;
		rightDown = false;
		ButtonDown = false;
	}

	public void newFrame() mut
	{
		SDL.CaptureMouse(ButtonDown ? .True : .False);

		LeftFF = false;
		MiddleFF = false;
		RightFF = false;
		LeftDouble = false;

		leftRel = false;
		middleRel = false;
		rightRel = false;

		ButtonFF = false;
		ButtonReleased = false;

		scrollDelta = .Zero;
		moveDelta = .Zero;
	}

	public bool movedAmountFromOC(int amount) => Vec2.Dist(pos, posOnClick) > amount;

	public bool events(ref SDL.Event e, Window w) mut
	{
		var type = e.type;
		if(type == .MouseButtonDown)
		{
			if(!ButtonDown) posOnClick = pos;
			ButtonFF = true;
			ButtonDown = true;
			travelDist = 0;
			if(e.button.button == SDL.SDL_BUTTON_LEFT)
			{
				LeftFF = true;
				leftDown = true;
				if(e.button.clicks == 2 && PosEqPOR)
				{
					LeftDouble = true;
				}
			}
			if(e.button.button == SDL.SDL_BUTTON_MIDDLE)
			{
				MiddleFF = true;
				middleDown = true;
			}
			if(e.button.button == SDL.SDL_BUTTON_RIGHT)
			{
				RightFF = true;
				rightDown = true;
			}
		}
		if(type == .MouseButtonUp)
		{
			relPos = pos;
			if(ButtonDown) ButtonReleased = true;
			LeftDouble = false;
			if(e.button.button == SDL.SDL_BUTTON_LEFT)
			{
				if(leftDown) leftRel = true;
				leftDown = false;

			}
			if(e.button.button == SDL.SDL_BUTTON_MIDDLE)
			{
				if(middleDown) middleRel = true;
				middleDown = false;
			}
			if(e.button.button == SDL.SDL_BUTTON_RIGHT)
			{
				if(rightDown) rightRel = true;
				rightDown = false;
			}
			ButtonDown = leftDown || middleDown || rightDown;
		}

		if(type == .MouseMotion)
		{
			pos.x = e.motion.x;
			pos.y = e.motion.y;
			moveDelta.x += e.motion.xrel;
			moveDelta.y += e.motion.yrel;

			if(ButtonDown) travelDist += Vec2.Dist(pos, pos + moveDelta);
		}

		if(type == .MouseWheel)
		{
			scrollDelta.x = e.wheel.x;
			scrollDelta.y = e.wheel.y;
		}

		return e.type == .MouseMotion || e.type == .MouseButtonDown || e.type == .MouseButtonUp || e.type == .MouseWheel;
	}
}
