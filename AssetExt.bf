using System;
using System.Collections;
using System.IO;

namespace framework;

public enum AssetExt {
	[Comptime, OnCompile(.TypeInit)] public static void Cases() {
		let cases = scope String();
		HashSet<String> types = scope .();
		let name = scope $"", ext = scope $"";
		for(let f in Directory.EnumerateFiles(Static.assetsFolder)) {
			name.Clear();
			ext.Clear();
			f.GetFileName(name);
			Path.GetExtension(name, ext);
			ext.Set(ext.Substring(1));
			ext.Ptr[0] = ext.Ptr[0].ToUpper;
			if(!types.Contains(ext)) {
				cases.AppendF($"case {ext}; \n");
				types.Add(ext);
			}
		}
		cases.AppendF($"case Count;\n");
		Compiler.EmitTypeBody(typeof(Self), cases);
	}
}
