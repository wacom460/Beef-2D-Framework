using System;
using System.Collections;

namespace framework;

class Asset {
	[Comptime] public static Span<AssetType> GetAllOfExt(AssetExt ext) {
		List<AssetType> ret = scope .();
		for(let i < AssetType.Count) {
			let str = scope $"{i}";
			let extStr = scope $"{ext}";
			if(str.EndsWith(extStr)) ret.Add(i);
		}
		return ret;
	}
}