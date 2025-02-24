using System.Diagnostics;
using System;
using System.Collections;
using System.Interop;
using System.IO;
using SDL2;
using stb_image;
using System.Threading;

namespace framework;

public static class Util {
	public static T Scale<T>(T value, T fromMin, T fromMax, T toMin, T toMax)
		where T : operator T + T, operator T - T, operator T * T, operator T / T, operator T<=>T
	{
		if(fromMin == fromMax) return toMin;
		T ret = ((toMax - toMin) * (value - fromMin) / (fromMax - fromMin)) + toMin;
		return ret;
	}

	public static T ScaleClamped<T>(T value, T fromMin, T fromMax, T toMin, T toMax)
		where T : operator T + T, operator T - T, operator T * T, operator T / T, operator T<=>T
	{
		if(fromMin == fromMax) return toMin;
		T ret = ((toMax - toMin) * (value - fromMin) / (fromMax - fromMin)) + toMin;
		if(ret < toMin) ret = toMin;
		if(ret > toMax) ret = toMax;
		return ret;
	}

	public static T Clamped<T>(T value, T min, T max) where T : operator T + T, operator T - T, operator T * T, operator T / T, operator T<=>T {
		if (value < min) return min;
		else if (value > max) return max;
		return value;
	}

	public static void GetNameStrs(FileFindEntry f, String name, String nameOg, String nameNoExt, String ext) {
		f.GetFileName(name);
		nameOg.Set(name);
		name.Replace(' ', '_');
		name.Replace('-', '_');
		Path.GetFileNameWithoutExtension(name, nameNoExt);
		Path.GetExtension(name, ext);
		ext.Replace('.', '_');
		ext.Set(ext.Substring(1));
		ext.Set(scope $"{ext.Substring(0, 1)[0].ToUpper}{ext.Substring(1, ext.Length - 1)}");
	}

	public static void OpenFile(String path) {
#if BF_PLATFORM_WINDOWS
		Windows.ShellExecuteA(0, "open", path, null, null, Windows.SW_SHOWNORMAL);
#endif
#if BF_PLATFORM_LINUX
	let psi = scope ProcessStartInfo();
	psi.SetFileName("xdg-open");
	psi.SetArguments(path);
	scope SpawnedProcess().Start(psi);
#endif
	}

	public static void WriteStrToFile(String text, String path) {
		File.WriteAllText(path, text);
	}

	public static void ShowInExplorerRelativePath(String relPath)
	{
		String absolutePath = scope .();
		Path.GetAbsolutePath(relPath, "", absolutePath);
		ShowInExplorer(absolutePath);
	}

	public static void ShowInExplorer(String fileLoc)
	{
		String fileNameWithArguments = scope String();
		fileNameWithArguments.AppendF("explorer.exe /select,\"{}\"", fileLoc);
		SpawnedProcess process = scope SpawnedProcess();
		ProcessStartInfo info = scope ProcessStartInfo();
		info.SetFileNameAndArguments(fileNameWithArguments);
		process.Start(info);
	}

	public static mixin FilenameSafeTimestamp()
	{
		String dtStr = scope:mixin .();
		DateTime.Now.ToString(dtStr);
		dtStr.Replace('/', '_');
		dtStr.Replace(':', '_');
		dtStr
	}

	public static void OpenURL(String str) {
		ProcessStartInfo p = scope .();
		p.SetFileName(str);
		p.UseShellExecute = true;
		scope SpawnedProcess().Start(p);
	}

	public static void RenderImageRect(Window w, SDL.Texture* texture, TextureAtlas.AtlasLoc loc, Rect dstRect, Color col = .White)
	{
		Debug.Assert(texture != null);
		DrawList dl = scope .(w);
		dl.fillBox(dstRect, col, loc);
		dl.render(texture);
	}
}
