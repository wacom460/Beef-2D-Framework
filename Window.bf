using System;
using SDL2;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Threading;
using Bon;

namespace framework;

abstract class Window {
	public bool open = true, focus;
	public SDL.Window* sdlWindow ~ SDL.DestroyWindow(_);
	public SDL.Renderer* renderer ~ SDL.DestroyRenderer(_);
	public MouseContext mouse = .();
	public append String title;
	public Vec2 winSize = .(640, 480);
	public TextureAtlas atlas ~ SafeDel!(_);
	public append DrawList dl = .(this);
	
	uint8[(.)SDL.Scancode.NUMSCANCODES] kbBuf;
	public bool anyKeyRel = false, anyKeyFF = false, anyKeyRep = false;
	
	public void regenAtlas() {
		SafeReplace!(atlas, new TextureAtlas(this));
	}

	public DrawList finalizeDrawList()
	{
		if(dl != null)
		{
			dl.render(atlas.tex);
#if DEBUG
			if(DrawList.DisableScissor) {
				let wireframe = scope DrawList(this);
				dl.scissorStack.Clear();
				let tc = dl.tris.Count;
				for(let ti < tc) wireframe.tri(dl[ti], .Yellow, 0.5f);
				wireframe.render(atlas.tex);
			}
#endif
			dl.clear();
		}
		return dl;
	}

	public bool kbD(SDL.Scancode key) => (kbBuf[(.)key] & 0x1) > 0;
	public bool kbR(SDL.Scancode key) => (kbBuf[(.)key] & 0x2) > 0;
	public bool kbFF(SDL.Scancode key) => (kbBuf[(.)key] & 0x4) > 0;
	public bool kbRep(SDL.Scancode key) => (kbBuf[(.)key] & 0x8) > 0 || kbFF(key);

	public abstract void init();
	public abstract void tick();
	public bool onExit() => true;

	public void setTitle(String title) => SDL.SetWindowTitle(sdlWindow, title.CStr());
	public static operator SDL.Window*(Window w) => w.sdlWindow;
	public void show() => SDL.ShowWindow(sdlWindow);
	public void hide() => SDL.HideWindow(sdlWindow);
	public void raise() => SDL.RaiseWindow(sdlWindow);
	public void maximize() => SDL.MaximizeWindow(this);
	public void setSize(Vec2 vec2i) => SDL.SetWindowSize(sdlWindow, (.)vec2i.x, (.)vec2i.y);

	public static void Start(Window win) {
		win.start();
	}

	void start() {
		gBonEnv.serializeFlags |= .Verbose | .IncludeDefault;
		let centered = SDL.WindowPosCenteredDisplay(0);
		sdlWindow = SDL.CreateWindow(title, (.)centered, (.)centered, (.)winSize.x, (.)winSize.y, .Shown);
		renderer = SDL.CreateRenderer(sdlWindow, -1, .Accelerated);
		Debug.Assert(renderer != null);
		SDL.SetRenderDrawBlendMode(renderer, .Blend);
		SDL.Init(.Video | .Events);
		//SDL.SetHint(SDL.SDL_HINT_RENDER_SCALE_QUALITY, "2");
		atlas = new .(this);
		regenAtlas();
		init();
		while(open) frame();
	}

	public ~this() {
		SDL.Quit();
	}

	public void close() {
		if(onExit()) {
			hide();
			open = false;
		}
	}

	public void frame() {
		mouse.newFrame();
		SDL.Event e;
		while (SDL.PollEvent(out e) != 0) {
			mouse.events(ref e, this);
			let key = ref e.key.keysym.scancode;
			switch(e.type) {
			case .KeyDown:
				if(e.key.isRepeat == 0) {
					anyKeyFF = true;
					kbBuf[(.)key] |= 1UL << 0;
					kbBuf[(.)key] |= 1UL << 2;
				} else {
					anyKeyRep = true;
					kbBuf[(.)key] |= 1UL << 3;
				}
			case .KeyUp:
				anyKeyRel = true;
				kbBuf[(.)key] |= 1UL << 1;
				kbBuf[(.)key] &= ~(1UL << 0);
			case .WindowEvent:
				let we = e.window.windowEvent;
				if(we == .Resized) {
					int32 w = 0;
					int32 h = 0;
					SDL.GetWindowSize(this, out w, out h);
					winSize = .((.)w, (.)h);
					regenAtlas();
				}
				if(we == .Focus_lost) focus = false;
				if(we == .FocusGained) focus = true;
				if(we == .Close) close();
			default:
			}
		}

		dl.fillBox(winSize, .Black);
		tick();
		finalizeDrawList();
		SDL.RenderPresent(renderer);

		if(anyKeyRel) {
			for(var k in ref kbBuf) k &= ~(1UL << 1);
			anyKeyRel = false;
		}

		if(anyKeyFF) {
			for(var k in ref kbBuf) k &= ~(1UL << 2);
			anyKeyFF = false;
		}

		if(anyKeyRep) {
			for(var k in ref kbBuf) k &= ~(1UL << 3);
			anyKeyRep = false;
		}

		SDL.Delay(16);
	}
}
