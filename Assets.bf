using System;
using System.IO;
using System.Diagnostics;

namespace framework;

class Assets {
	[Comptime, OnCompile(.TypeInit)] public static void IncludeAssets() {
		let staticLets = scope $"";
		let content = scope $"", content2 = scope $"", content3 = scope $"";
		for(let f in Directory.EnumerateFiles(Static.assetsFolder)) {
			let name = scope $"", nameOg = scope $"", nameNoExt = scope $"", ext = scope $"";
			Util.GetNameStrs(f, name, nameOg, nameNoExt, ext);
			let isTxt = ext == "Txt", isIco = ext == "Ico", isC = ext == "C";
			if(!isIco) staticLets.AppendF($"""
				public static let {nameNoExt}{ext}_Data = Compiler.{isTxt || isC ? "ReadText" : "ReadBinary"}(\"{Static.assetsFolder}/{nameOg}\"){
					let a = scope String();
					if(isTxt) {
						a.AppendF($", {nameNoExt}{ext}_FileName = \"{nameOg}\"");
					}
					a
				};
				""");
			if(isC || isTxt) {
				content2.AppendF($"\n\tif(type == .{nameNoExt}{ext}) outText.Append(\"{name}\");");
				content3.AppendF($"\n\tif(fileName == \"{name}\") outText.Append({nameNoExt}{ext}_Data);");
			}
			if(!isTxt && !isIco && !isC) content.AppendF($"""
				case .{nameNoExt}{ext}: return {nameNoExt}{ext}_Data;
				\t
				""");
		}
		Compiler.EmitTypeBody(typeof(Self), scope $"""
			{staticLets}
			public static Span<uint8> Get(AssetType type) {{
				switch(type) {{
				{content}default: {{
					Runtime.FatalError();
				}}
				}}
			}}

			public static void GetNameOf(AssetType type, String outText) {{{content2}
			}}

			public static void GetText(String fileName, String outText) {{{content3}
			}}
			""");
	}
}