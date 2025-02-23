using System.Collections;
using System;
using System.IO;

namespace framework;

static {
	public static mixin Nullify(var val) => val = null;
	public static mixin SafeDel(var val) => SafeReplace!(val, null);
	public static mixin SafeReplace(var val, var with) {
		let v = val;
		val = with;
		if(v != null) delete v;
	}
}

class Static {
	public const var Arch =
#if BF_32_BIT
		"32-bit"
#elif BF_64_BIT
		"64-bit"
#else
		"Unknown"
#endif
		;

	public const bool DebugMode = 
#if DEBUG
		true
#else
		false
#endif
		;

	public const bool Is32Bit =
#if BF_32_BIT
		true
#elif BF_64_BIT
		false
#endif
		;
	
	public const let assetsFolder = "assets";
}

namespace SDL2;

extension SDL {
	extension Vertex {
		public this(FPoint position, Color color, FPoint texCoord = .()) {
			this.position = position;
			this.color = color;
			this.tex_coord = texCoord;
		}
	}
	extension FPoint {
		public new this(float x, float y) {
			this.x = x;
			this.y = y;
		}
	}
	extension MessageBoxButtonData {
		public this(MessageBoxButtonFlags flags, int32 buttonid, char8* text) {
			this.flags = flags;
			this.buttonid = buttonid;
			this.text = text;
		}
	}
	extension MessageBoxData {
		public this(MessageBoxFlags flags,
			Window* window,
			char8* title,
			char8* message,
			int32 numbuttons,
			MessageBoxButtonData* buttons,
			MessageBoxColorScheme* colorScheme
		)
		{
			this.flags = flags;
			this.window = window;
			this.title = title;
			this.message = message;
			this.numbuttons = numbuttons;
			this.buttons = buttons;
			this.colorScheme = colorScheme;
		}
	}
}
