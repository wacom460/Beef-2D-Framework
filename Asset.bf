using System;
using System.Collections;

namespace framework;

class Asset {
	public static mixin GetAllOfExt(AssetExt ext) {
		List<AssetType> ret = scope:mixin .();
		for(let i < AssetType.Count) {
			let str = scope:mixin $"{i}", extStr = scope:mixin $"{ext}";
			if(str.EndsWith(extStr))
				ret.Add(i);
		}
		ret
	}
}