using System;
using System.IO;
using System.Collections;
using Bon;

namespace framework;

[BonTarget] public enum AssetType {
	[Comptime, OnCompile(.TypeInit)]
	public static void Cases() {
		let cases = scope $"";
		for(let f in Directory.EnumerateFiles(Static.assetsFolder)) {
			let name = scope $"", nameOg = scope $"", nameNoExt = scope $"", ext = scope $"";
			Util.GetNameStrs(f, name, nameOg, nameNoExt, ext);
			let isIco = ext == "Ico";
			if(!isIco) cases.AppendF($"case {nameNoExt}{ext}; \n");
		}
		cases.Append($"case Count;\n");
		Compiler.EmitTypeBody(typeof(Self), cases);
	}
}