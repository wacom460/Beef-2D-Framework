// stb_truetype.h - v1.26 - public domain
// authored from 2009-2021 by Sean Barrett / RAD Game Tools
//
// =======================================================================
//
//    NO SECURITY GUARANTEE -- DO NOT USE THIS ON UNTRUSTED FONT FILES
//
// This library does no range checking of the offsets found in the file,
// meaning an attacker can use it to read arbitrary memory.
//
// =======================================================================
// LICENSE
// See end of file for license information.

// original file and documentation/usage: https://github.com/nothings/stb/blob/master/stb_truetype.h
// ported at c0c9826

using System;

namespace stb_truetype
{
	public struct stbtt__buf
	{
		public uint8* data;
		public int32 cursor;
		public int32 size;
	}

	public struct stbtt_bakedchar
	{
		public uint16 x0, y0, x1, y1;// coordinates of bbox in bitmap
		public float xoff, yoff, xadvance;
	}

	public struct stbtt_aligned_quad
	{
		public float x0, y0, s0, t0;// top-left
		public float x1, y1, s1, t1;// bottom-right
	}

	public struct stbtt_packedchar
	{
		public uint16 x0, y0, x1, y1;// coordinates of bbox in bitmap
		public float xoff, yoff, xadvance;
		public float xoff2, yoff2;
	}

	public struct stbtt_pack_range
	{
		public float font_size;
		public int32 first_unicode_codepoint_in_range;// if non-zero, then the chars are continuous, and this is the
		// first codepoint
		public int32* array_of_unicode_codepoints;// if non-zero, then this is an array of unicode codepoints
		public int32 num_chars;
		public stbtt_packedchar* chardata_for_range;// output
		public uint8 h_oversample, v_oversample;// don't set these, they're used internally
	}

	struct stbtt_pack_context
	{
		public void* user_allocator_context;
		public void* pack_info;
		public int32 width;
		public int32 height;
		public int32 stride_in_bytes;
		public int32 padding;
		public bool skip_missing;
		public uint32 h_oversample, v_oversample;
		public uint8* pixels;
		public void* nodes;
	}

	public struct stbtt_fontinfo
	{
		public void* userdata;
		public uint8* data;// pointer to .ttf file
		public int32 fontstart;// offset of start of font

		public int32 numGlyphs;// number of glyphs, needed for range checking

		public int32 loca, head, glyf, hhea, hmtx, kern, gpos, svg;// table locations as offset from start of .ttf
		public int32 index_map;// a cmap mapping for our chosen character encoding
		public int32 indexToLocFormat;// format needed to map from glyph index to glyph

		public stbtt__buf cff;// cff font data
		public stbtt__buf charstrings;// the charstring index
		public stbtt__buf gsubrs;// global charstring subroutines index
		public stbtt__buf subrs;// private charstring subroutines index
		public stbtt__buf fontdicts;// array of font dicts
		public stbtt__buf fdselect;// map from glyph to fontdict
	}

	public struct stbtt_kerningentry
	{
		public int32 glyph1;// use stbtt_FindGlyphIndex
		public int32 glyph2;
		public int32 advance;
	}

	typealias stbtt_vertex_type = int16;
	public struct stbtt_vertex
	{
		public stbtt_vertex_type x, y, cx, cy, cx1, cy1;
		public uint8 type, padding;
	}

	// @TODO: don't expose this structure
	public struct stbtt__bitmap
	{
		public int32 w, h, stride;
		public uint8* pixels;
	}

	static class stbtt
	{
		typealias stbtt_uint8 = uint8;
		typealias stbtt_int8 = int8;
		typealias stbtt_uint16 = uint16;
		typealias stbtt_int16 = int16;
		typealias stbtt_uint32 = uint32;
		typealias stbtt_int32 = int32;

		// @PORT: when STB_RECT_PACK_VERSION is defined, i think this uses
		// that for packing. Do this here always(?) when we have ported it

		static mixin STBTT_POINT_SIZE(var x)
		{
			(-(x))
		}

		static mixin STBTT_ifloor(var x)
		{
			(int32)Math.Floor(x)
		}
		static mixin STBTT_iceil(var x)
		{
			(int32)Math.Ceiling(x)
		}

		static mixin STBTT_sqrt(var x)
		{
			Math.Sqrt(x)
		}
		static mixin STBTT_pow(var x, var y)
		{
			Math.Pow(x, y)
		}

		static mixin STBTT_fmod(var x, var y)
		{
			(x % y)
		}

		static mixin STBTT_cos(var x)
		{
			Math.Cos(x)
		}
		static mixin STBTT_acos(var x)
		{
			Math.Acos(x)
		}

		static mixin STBTT_fabs(var x)
		{
			Math.Abs(x)
		}

		static mixin STBTT_malloc(var x, void* u)
		{
			Internal.Malloc(x)
		}
		static mixin STBTT_free(var x, void* u)
		{
			if(x != null) Internal.Free(x);
		}

		static mixin STBTT_assert(bool x)
		{
			Runtime.Assert(x);
		}

		static mixin STBTT_strlen(var x)
		{
			String.StrLen((char8*)x)
		}

		static mixin STBTT_memcpy(void* dest, void* src, int32 len)
		{
			Internal.MemCpy(dest, src, len);
		}

		static mixin STBTT_memset(void* ptr, uint8 val, int32 len)
		{
			Internal.MemSet(ptr, val, len);
		}

		public const int STBTT_vmove = 1,
			STBTT_vline = 2,
			STBTT_vcurve = 3,
			STBTT_vcubic = 4;

		public const int
			STBTT_MACSTYLE_DONTCARE = 0,
			STBTT_MACSTYLE_BOLD = 1,
			STBTT_MACSTYLE_ITALIC = 2,
			STBTT_MACSTYLE_UNDERSCORE = 4,
			STBTT_MACSTYLE_NONE = 8;// <= not same as 0, this makes us check the bitfield is 0

		public const int// platformID
			STBTT_PLATFORM_ID_UNICODE = 0,
			STBTT_PLATFORM_ID_MAC = 1,
			STBTT_PLATFORM_ID_ISO = 2,
			STBTT_PLATFORM_ID_MICROSOFT = 3;

		public const int// encodingID
			// for STBTT_PLATFORM_ID_UNICODE
			STBTT_UNICODE_EID_UNICODE_1_0 = 0,
			STBTT_UNICODE_EID_UNICODE_1_1 = 1,
			STBTT_UNICODE_EID_ISO_10646 = 2,
			STBTT_UNICODE_EID_UNICODE_2_0_BMP = 3,
			STBTT_UNICODE_EID_UNICODE_2_0_FULL = 4,
			
			// for STBTT_PLATFORM_ID_MICROSOFT
			STBTT_MS_EID_SYMBOL = 0,
			STBTT_MS_EID_UNICODE_BMP = 1,
			STBTT_MS_EID_SHIFTJIS = 2,
			STBTT_MS_EID_UNICODE_FULL = 10,
			
			// for STBTT_PLATFORM_ID_MAC; same as Script Manager codes
			STBTT_MAC_EID_ROMAN = 0, STBTT_MAC_EID_ARABIC = 4,
			STBTT_MAC_EID_JAPANESE = 1, STBTT_MAC_EID_HEBREW = 5,
			STBTT_MAC_EID_CHINESE_TRAD = 2, STBTT_MAC_EID_GREEK = 6,
			STBTT_MAC_EID_KOREAN = 3, STBTT_MAC_EID_RUSSIAN = 7;

		public const int// languageID
			// for STBTT_PLATFORM_ID_MICROSOFT; same as LCID...
			// problematic because there are e.g. 16 english LCIDs and 16 arabic LCIDs
			STBTT_MS_LANG_ENGLISH = 0x0409, STBTT_MS_LANG_ITALIAN = 0x0410,
			STBTT_MS_LANG_CHINESE = 0x0804, STBTT_MS_LANG_JAPANESE = 0x0411,
			STBTT_MS_LANG_DUTCH = 0x0413, STBTT_MS_LANG_KOREAN = 0x0412,
			STBTT_MS_LANG_FRENCH = 0x040c, STBTT_MS_LANG_RUSSIAN = 0x0419,
			STBTT_MS_LANG_GERMAN = 0x0407, STBTT_MS_LANG_SPANISH = 0x0409,// @NOTE: STBTT_MS_LANG_SPANISH == STBTT_MS_LANG_ENGLISH seems wrong???
			STBTT_MS_LANG_HEBREW = 0x040d, STBTT_MS_LANG_SWEDISH = 0x041D,
			
			// for STBTT_PLATFORM_ID_MAC
			STBTT_MAC_LANG_ENGLISH = 0, STBTT_MAC_LANG_JAPANESE = 11,
			STBTT_MAC_LANG_ARABIC = 12, STBTT_MAC_LANG_KOREAN = 23,
			STBTT_MAC_LANG_DUTCH = 4, STBTT_MAC_LANG_RUSSIAN = 32,
			STBTT_MAC_LANG_FRENCH = 1, STBTT_MAC_LANG_SPANISH = 6,
			STBTT_MAC_LANG_GERMAN = 2, STBTT_MAC_LANG_SWEDISH = 5,
			STBTT_MAC_LANG_HEBREW = 10, STBTT_MAC_LANG_CHINESE_SIMPLIFIED = 33,
			STBTT_MAC_LANG_ITALIAN = 3, STBTT_MAC_LANG_CHINESE_TRAD = 19;

		const int STBTT_MAX_OVERSAMPLE = 8;

#if !STBTT_RASTERIZER_VERSION_1
#define STBTT_RASTERIZER_VERSION_2
#endif

		static stbtt_uint8 stbtt__buf_get8(stbtt__buf* b)
		{
			if (b.cursor >= b.size)
				return 0;
			return b.data[b.cursor++];
		}

		static stbtt_uint8 stbtt__buf_peek8(stbtt__buf* b)
		{
			if (b.cursor >= b.size)
				return 0;
			return b.data[b.cursor];
		}

		static void stbtt__buf_seek(stbtt__buf* b, int32 o)
		{
			STBTT_assert!(!(o > b.size || o < 0));
			b.cursor = (o > b.size || o < 0) ? b.size : o;
		}

		static void stbtt__buf_skip(stbtt__buf* b, int32 o)
		{
			stbtt__buf_seek(b, b.cursor + o);
		}

		static stbtt_uint32 stbtt__buf_get(stbtt__buf* b, int32 n)
		{
			stbtt_uint32 v = 0;
			int32 i;
			STBTT_assert!(n >= 1 && n <= 4);
			for (i = 0; i < n; i++)
				v = (v << 8) | stbtt__buf_get8(b);
			return v;
		}

		static stbtt__buf stbtt__new_buf(void* p, int size)
		{
			stbtt__buf r;
			STBTT_assert!(size < 0x40000000);
			r.data = (stbtt_uint8*)p;
			r.size = (int32)size;
			r.cursor = 0;
			return r;
		}

		[Inline]
		static stbtt_uint32 stbtt__buf_get16(stbtt__buf* b)
		{
			return stbtt__buf_get((b), 2);
		}
		[Inline]
		static stbtt_uint32 stbtt__buf_get32(stbtt__buf* b)
		{
			return stbtt__buf_get((b), 4);
		}

		static stbtt__buf stbtt__buf_range(stbtt__buf* b, int32 o, int32 s)
		{
			stbtt__buf r = stbtt__new_buf(null, 0);
			if (o < 0 || s < 0 || o > b.size || s > b.size - o) return r;
			r.data = b.data + o;
			r.size = s;
			return r;
		}

		static stbtt__buf stbtt__cff_get_index(stbtt__buf* b)
		{
			int32 count, start, offsize;
			start = b.cursor;
			count = (int32)stbtt__buf_get16(b);
			if (count != 0)
			{
				offsize = stbtt__buf_get8(b);
				STBTT_assert!(offsize >= 1 && offsize <= 4);
				stbtt__buf_skip(b, offsize * count);
				stbtt__buf_skip(b, (int32)stbtt__buf_get(b, offsize) - 1);
			}
			return stbtt__buf_range(b, start, b.cursor - start);
		}

		static stbtt_uint32 stbtt__cff_int(stbtt__buf* b)
		{
			int32 b0 = stbtt__buf_get8(b);
			if (b0 >= 32 && b0 <= 246) return (uint32)(b0 - 139);
			else if (b0 >= 247 && b0 <= 250) return (uint32)((b0 - 247) * 256 + stbtt__buf_get8(b) + 108);
			else if (b0 >= 251 && b0 <= 254) return (uint32)(-(b0 - 251) * 256 - stbtt__buf_get8(b) - 108);
			else if (b0 == 28) return stbtt__buf_get16(b);
			else if (b0 == 29) return stbtt__buf_get32(b);
			STBTT_assert!(false);
			return 0;
		}

		static void stbtt__cff_skip_operand(stbtt__buf* b)
		{
			int32 v, b0 = stbtt__buf_peek8(b);
			STBTT_assert!(b0 >= 28);
			if (b0 == 30)
			{
				stbtt__buf_skip(b, 1);
				while (b.cursor < b.size)
				{
					v = stbtt__buf_get8(b);
					if ((v & 0xF) == 0xF || (v >> 4) == 0xF)
						break;
				}
			} else
			{
				stbtt__cff_int(b);
			}
		}

		static stbtt__buf stbtt__dict_get(stbtt__buf* b, int32 key)
		{
			stbtt__buf_seek(b, 0);
			while (b.cursor < b.size)
			{
				int32 start = b.cursor, end, op;
				while (stbtt__buf_peek8(b) >= 28)
					stbtt__cff_skip_operand(b);
				end = b.cursor;
				op = stbtt__buf_get8(b);
				if (op == 12) op = (int32)(stbtt__buf_get8(b) | 0x100);
				if (op == key) return stbtt__buf_range(b, start, end - start);
			}
			return stbtt__buf_range(b, 0, 0);
		}

		static void stbtt__dict_get_ints(stbtt__buf* b, int32 key, int32 outcount, stbtt_uint32* _out)
		{
			int32 i;
			stbtt__buf operands = stbtt__dict_get(b, key);
			for (i = 0; i < outcount && operands.cursor < operands.size; i++)
				_out[i] = stbtt__cff_int(&operands);
		}

		static int32 stbtt__cff_index_count(stbtt__buf* b)
		{
			stbtt__buf_seek(b, 0);
			return (int32)stbtt__buf_get16(b);
		}

		static stbtt__buf stbtt__cff_index_get(stbtt__buf b, int32 i)
		{
			var b;

			int32 count, offsize, start, end;
			stbtt__buf_seek(&b, 0);
			count = (int32)stbtt__buf_get16(&b);
			offsize = stbtt__buf_get8(&b);
			STBTT_assert!(i >= 0 && i < count);
			STBTT_assert!(offsize >= 1 && offsize <= 4);
			stbtt__buf_skip(&b, i * offsize);
			start = (int32)stbtt__buf_get(&b, offsize);
			end = (int32)stbtt__buf_get(&b, offsize);
			return stbtt__buf_range(&b, 2 + (count + 1) * offsize + start, end - start);
		}

		//////////////////////////////////////////////////////////////////////////
		//
		// accessors to parse data from file
		//

		// on platforms that don't allow misaligned reads, if we want to allow
		// truetype fonts that aren't padded to alignment, define ALLOW_UNALIGNED_TRUETYPE

		static mixin ttBYTE(var p)
		{
			(*(stbtt_uint8*)(p))
		}
		static mixin ttCHAR(var p)
		{
			(*(stbtt_int8*)(p))
		}
		static mixin ttFixed(var p)
		{
			ttLONG(p)
		}

		[Inline]
		static stbtt_uint16 ttUSHORT(stbtt_uint8* p) { return (uint16)((uint32)p[0]) * 256 + p[1]; }
		[Inline, DisableChecks]
		static stbtt_int16 ttSHORT(stbtt_uint8* p) { return (int16)((int32)p[0]) * 256 + p[1]; }
		[Inline]
		static stbtt_uint32 ttULONG(stbtt_uint8* p) { return (((uint32)p[0]) << 24) + (((uint32)p[1]) << 16) + (((uint32)p[2]) << 8) + p[3]; }
		[Inline]
		static stbtt_int32 ttLONG(stbtt_uint8* p) { return (((int32)p[0]) << 24) + (((int32)p[1]) << 16) + (((int32)p[2]) << 8) + p[3]; }

		static mixin stbtt_tag4(stbtt_uint8* p, uint8 c0, uint8 c1, uint8 c2, uint8 c3)
		{
			((p)[0] == (c0) && (p)[1] == (c1) && (p)[2] == (c2) && (p)[3] == (c3))
		}

		static mixin stbtt_tag(stbtt_uint8* p, char8* str)
		{
			stbtt_tag4!(p, (uint8)str[0], (uint8)str[1], (uint8)str[2], (uint8)str[3])
		}

		public static bool stbtt__isfont(stbtt_uint8* font)
		{
		   // check the version number
			if (stbtt_tag4!(font, (uint8)'1', 0, 0, 0)) return true;// TrueType 1
			if (stbtt_tag!(font, "typ1")) return true;// TrueType with type 1 font -- we don't support this!
			if (stbtt_tag!(font, "OTTO")) return true;// OpenType with CFF
			if (stbtt_tag4!(font, 0, 1, 0, 0)) return true;// OpenType 1.0
			if (stbtt_tag!(font, "true")) return true;// Apple specification for TrueType fonts
			return false;
		}

		// @OPTIMIZE: binary search
		static stbtt_uint32 stbtt__find_table(stbtt_uint8* data, stbtt_uint32 fontstart, char8* tag)
		{
			stbtt_int32 num_tables = ttUSHORT(data + fontstart + 4);
			stbtt_uint32 tabledir = fontstart + 12;
			stbtt_int32 i;
			for (i = 0; i < num_tables; ++i)
			{
				stbtt_uint32 loc = tabledir + 16 * ((.)i);
				if (stbtt_tag!(data + loc + 0, tag))
					return ttULONG(data + loc + 8);
			}
			return 0;
		}

		static int32 stbtt_GetFontOffsetForIndex_internal(uint8* font_collection, int32 index)
		{
		   // if it's just a font, there's only one valid index
			if (stbtt__isfont(font_collection))
				return index == 0 ? 0 : -1;

		   // check if it's a TTC
			if (stbtt_tag!(font_collection, "ttcf"))
			{
			  // version 1?
				if (ttULONG(font_collection + 4) == 0x00010000 || ttULONG(font_collection + 4) == 0x00020000)
				{
					stbtt_int32 n = ttLONG(font_collection + 8);
					if (index >= n)
						return -1;
					return (.)ttULONG(font_collection + 12 + index * 4);
				}
			}
			return -1;
		}

		static int32 stbtt_GetNumberOfFonts_internal(uint8* font_collection)
		{
		   // if it's just a font, there's only one valid font
			if (stbtt__isfont(font_collection))
				return 1;

		   // check if it's a TTC
			if (stbtt_tag!(font_collection, "ttcf"))
			{
			  // version 1?
				if (ttULONG(font_collection + 4) == 0x00010000 || ttULONG(font_collection + 4) == 0x00020000)
				{
					return ttLONG(font_collection + 8);
				}
			}
			return 0;
		}

		static stbtt__buf stbtt__get_subrs(stbtt__buf cff, stbtt__buf fontdict)
		{
			var fontdict, cff;

			stbtt_uint32 subrsoff = 0;
			stbtt_uint32[2] private_loc = default;
			stbtt__buf pdict;
			stbtt__dict_get_ints(&fontdict, 18, 2, &private_loc[0]);
			if (private_loc[1] == 0 || private_loc[0] == 0) return stbtt__new_buf(null, 0);
			pdict = stbtt__buf_range(&cff, (.)private_loc[1], (.)private_loc[0]);
			stbtt__dict_get_ints(&pdict, 19, 1, &subrsoff);
			if (subrsoff == 0) return stbtt__new_buf(null, 0);
			stbtt__buf_seek(&cff, (.)(private_loc[1] + subrsoff));
			return stbtt__cff_get_index(&cff);
		}

		// since most people won't use this, find this table the first time it's needed
		static int32 stbtt__get_svg(stbtt_fontinfo* info)
		{
			stbtt_uint32 t;
			if (info.svg < 0)
			{
				t = stbtt__find_table(info.data, (uint32)info.fontstart, "SVG ");
				if (t != 0)
				{
					stbtt_uint32 offset = ttULONG(info.data + t + 2);
					info.svg = (.)(t + offset);
				} else
				{
					info.svg = 0;
				}
			}
			return info.svg;
		}

		static bool stbtt_InitFont_internal(stbtt_fontinfo* info, uint8* data, int32 fontstart)
		{
			stbtt_uint32 cmap, t;
			stbtt_int32 i, numTables;

			info.data = data;
			info.fontstart = fontstart;
			info.cff = stbtt__new_buf(null, 0);

			cmap = stbtt__find_table(data, (uint32)fontstart, "cmap");// required
			info.loca = (.)stbtt__find_table(data, (uint32)fontstart, "loca");// required
			info.head = (.)stbtt__find_table(data, (uint32)fontstart, "head");// required
			info.glyf = (.)stbtt__find_table(data, (uint32)fontstart, "glyf");// required
			info.hhea = (.)stbtt__find_table(data, (uint32)fontstart, "hhea");// required
			info.hmtx = (.)stbtt__find_table(data, (uint32)fontstart, "hmtx");// required
			info.kern = (.)stbtt__find_table(data, (uint32)fontstart, "kern");// not required
			info.gpos = (.)stbtt__find_table(data, (uint32)fontstart, "GPOS");// not required

			if (cmap == 0 || info.head == 0 || info.hhea == 0 || info.hmtx == 0)
				return false;
			if (info.glyf != 0)
			{
			   // required for truetype
				if (info.loca == 0) return false;
			} else
			{
			   // initialization for CFF / Type2 fonts (OTF)
				stbtt__buf b, topdict, topdictidx;
				stbtt_uint32 cstype = 2, charstrings = 0, fdarrayoff = 0, fdselectoff = 0;
				stbtt_uint32 cff;

				cff = stbtt__find_table(data, (.)fontstart, "CFF ");
				if (cff == 0) return false;

				info.fontdicts = stbtt__new_buf(null, 0);
				info.fdselect = stbtt__new_buf(null, 0);

			   // @TODO this should use size from table (not 512MB)
				info.cff = stbtt__new_buf(data + cff, 512 * 1024 * 1024);
				b = info.cff;

			   // read the header
				stbtt__buf_skip(&b, 2);
				stbtt__buf_seek(&b, stbtt__buf_get8(&b));// hdrsize

			   // @TODO the name INDEX could list multiple fonts,
			   // but we just use the first one.
				stbtt__cff_get_index(&b);// name INDEX
				topdictidx = stbtt__cff_get_index(&b);
				topdict = stbtt__cff_index_get(topdictidx, 0);
				stbtt__cff_get_index(&b);// string INDEX
				info.gsubrs = stbtt__cff_get_index(&b);

				stbtt__dict_get_ints(&topdict, 17, 1, &charstrings);
				stbtt__dict_get_ints(&topdict, 0x100 | 6, 1, &cstype);
				stbtt__dict_get_ints(&topdict, 0x100 | 36, 1, &fdarrayoff);
				stbtt__dict_get_ints(&topdict, 0x100 | 37, 1, &fdselectoff);
				info.subrs = stbtt__get_subrs(b, topdict);

			   // we only support Type 2 charstrings
				if (cstype != 2) return false;
				if (charstrings == 0) return false;

				if (fdarrayoff != 0)
				{
				  // looks like a CID font
					if (fdselectoff == 0) return false;
					stbtt__buf_seek(&b, (.)fdarrayoff);
					info.fontdicts = stbtt__cff_get_index(&b);
					info.fdselect = stbtt__buf_range(&b, (.)fdselectoff, b.size - (.)fdselectoff);
				}

				stbtt__buf_seek(&b, (.)charstrings);
				info.charstrings = stbtt__cff_get_index(&b);
			}

			t = stbtt__find_table(data, (.)fontstart, "maxp");
			if (t != 0)
				info.numGlyphs = ttUSHORT(data + t + 4);
			else
				info.numGlyphs = 0xffff;

			info.svg = -1;

			// find a cmap encoding table we understand *now* to avoid searching
			// later. (todo: could make this installable)
			// the same regardless of glyph.
			numTables = ttUSHORT(data + cmap + 2);
			info.index_map = 0;
			for (i = 0; i < numTables; ++i)
			{
				stbtt_uint32 encoding_record = cmap + 4 + 8 * (.)i;
				// find an encoding we understand:
				switch (ttUSHORT(data + encoding_record)) {
				case STBTT_PLATFORM_ID_MICROSOFT:
					switch (ttUSHORT(data + encoding_record + 2)) {
					case STBTT_MS_EID_UNICODE_BMP:
					case STBTT_MS_EID_UNICODE_FULL:
							// MS/Unicode
						info.index_map = (.)(cmap + ttULONG(data + encoding_record + 4));
						break;
					}
					break;
				case STBTT_PLATFORM_ID_UNICODE:
					  // Mac/iOS has these
					  // all the encodingIDs are unicode, so we don't bother to check it
					info.index_map = (.)(cmap + ttULONG(data + encoding_record + 4));
					break;
				}
			}
			if (info.index_map == 0)
				return false;

			info.indexToLocFormat = ttUSHORT(data + info.head + 50);
			return true;
		}

		public static int32 stbtt_FindGlyphIndex(stbtt_fontinfo* info, int32 unicode_codepoint)
		{
			stbtt_uint8* data = info.data;
			stbtt_uint32 index_map = (.)info.index_map;

			stbtt_uint16 format = ttUSHORT(data + index_map + 0);
			if (format == 0)
			{ // apple byte encoding
				stbtt_int32 bytes = ttUSHORT(data + index_map + 2);
				if (unicode_codepoint < bytes - 6)
					return ttBYTE!(data + index_map + 6 + unicode_codepoint);
				return 0;
			} else if (format == 6) {
				stbtt_uint32 first = ttUSHORT(data + index_map + 6);
				stbtt_uint32 count = ttUSHORT(data + index_map + 8);
				if ((stbtt_uint32)unicode_codepoint >= first && (stbtt_uint32)unicode_codepoint < first + count)
					return ttUSHORT(data + index_map + 10 + (unicode_codepoint - (.)first) * 2);
				return 0;
			} else if (format == 2) {
				STBTT_assert!(false); // @TODO: high-byte mapping for japanese/chinese/korean
				return 0;
			} else if (format == 4) {// standard mapping for windows fonts: binary search collection of ranges
				stbtt_uint16 segcount = ttUSHORT(data + index_map + 6) >> 1;
				stbtt_uint16 searchRange = ttUSHORT(data + index_map + 8) >> 1;
				stbtt_uint16 entrySelector = ttUSHORT(data + index_map + 10);
				stbtt_uint16 rangeShift = ttUSHORT(data + index_map + 12) >> 1;

				// do a binary search of the segments
				stbtt_uint32 endCount = index_map + 14;
				stbtt_uint32 search = endCount;

				if (unicode_codepoint > 0xffff)
					return 0;

				// they lie from endCount .. endCount + segCount
				// but searchRange is the nearest power of two, so...
				if (unicode_codepoint >= ttUSHORT(data + search + (uint32)rangeShift * 2))
					search += (uint32)rangeShift * 2;

				// now decrement to bias correctly to find smallest
				search -= 2;
				while (entrySelector != 0)
				{
					stbtt_uint16 end;
					searchRange >>= 1;
					end = ttUSHORT(data + search + (uint32)searchRange * 2);
					if (unicode_codepoint > end)
						search += (uint32)searchRange * 2;
					--entrySelector;
				}
				search += 2;
				{
					stbtt_uint16 offset, start, last;
					stbtt_uint16 item = (stbtt_uint16)((search - endCount) >> 1);

					start = ttUSHORT(data + index_map + 14 + segcount * 2 + 2 + 2 * item);
					last = ttUSHORT(data + endCount + 2 * item);
					if (unicode_codepoint < start || unicode_codepoint > last)
						return 0;

					offset = ttUSHORT(data + index_map + 14 + segcount * 6 + 2 + 2 * item);
					if (offset == 0)
						return (stbtt_uint16)(unicode_codepoint + ttSHORT(data + index_map + 14 + segcount * 4 + 2 + 2 * item));

					return ttUSHORT(data + offset + (unicode_codepoint - start) * 2 + index_map + 14 + segcount * 6 + 2 + 2 * item);
				}
			} else if (format == 12 || format == 13) {
				stbtt_uint32 ngroups = ttULONG(data + index_map + 12);
				stbtt_int32 low, high;
				low = 0; high = (stbtt_int32)ngroups;
				// Binary search the right group.
				while (low < high) {
					stbtt_int32 mid = low + ((high - low) >> 1);// rounds down, so low <= mid < high
					stbtt_uint32 start_char = ttULONG(data + index_map + 16 + mid * 12);
					stbtt_uint32 end_char = ttULONG(data + index_map + 16 + mid * 12 + 4);
					if ((stbtt_uint32)unicode_codepoint < start_char)
						high = mid;
					else if ((stbtt_uint32)unicode_codepoint > end_char)
						low = mid + 1;
					else
					{
						stbtt_uint32 start_glyph = ttULONG(data + index_map + 16 + mid * 12 + 8);
						if (format == 12)
							return (.)(start_glyph + (.)unicode_codepoint - start_char);
						else// format == 13
							return (.)start_glyph;
					}
				}
				return 0;// not found
			}
			// @TODO
			STBTT_assert!(false);
			return 0;
		}

		public static int32 stbtt_GetCodepointShape(stbtt_fontinfo* info, int32 unicode_codepoint, stbtt_vertex** vertices)
		{
			return stbtt_GetGlyphShape(info, stbtt_FindGlyphIndex(info, unicode_codepoint), vertices);
		}

		static void stbtt_setvertex(stbtt_vertex* v, stbtt_uint8 type, stbtt_int32 x, stbtt_int32 y, stbtt_int32 cx, stbtt_int32 cy)
		{
			v.type = type;
			v.x = (stbtt_int16)x;
			v.y = (stbtt_int16)y;
			v.cx = (stbtt_int16)cx;
			v.cy = (stbtt_int16)cy;
		}

		static int32 stbtt__GetGlyfOffset(stbtt_fontinfo* info, int32 glyph_index)
		{
			int32 g1, g2;

			STBTT_assert!(info.cff.size == 0);

			if (glyph_index >= info.numGlyphs) return -1;// glyph index out of range
			if (info.indexToLocFormat >= 2) return -1;// unknown index.glyph map format

			if (info.indexToLocFormat == 0)
			{
				g1 = info.glyf + (int32)ttUSHORT(info.data + info.loca + glyph_index * 2) * 2;
				g2 = info.glyf + (int32)ttUSHORT(info.data + info.loca + glyph_index * 2 + 2) * 2;
			} else {
				g1 = info.glyf + (.)ttULONG(info.data + info.loca + glyph_index * 4);
				g2 = info.glyf + (.)ttULONG(info.data + info.loca + glyph_index * 4 + 4);
			}

			return g1 == g2 ? -1 : g1;// if length is 0, return -1
		}

		public static bool stbtt_GetGlyphBox(stbtt_fontinfo* info, int32 glyph_index, int32* x0, int32* y0, int32* x1, int32* y1)
		{
			if (info.cff.size != 0)
			{
				stbtt__GetGlyphInfoT2(info, glyph_index, x0, y0, x1, y1);
			} else {
				int32 g = stbtt__GetGlyfOffset(info, glyph_index);
				if (g < 0) return false;

				if (x0 != null) *x0 = (int32)ttSHORT(info.data + g + 2);
				if (y0 != null) *y0 = (int32)ttSHORT(info.data + g + 4);
				if (x1 != null) *x1 = (int32)ttSHORT(info.data + g + 6);
				if (y1 != null) *y1 = (int32)ttSHORT(info.data + g + 8);
			}
			return true;
		}

		public static bool stbtt_GetCodepointBox(stbtt_fontinfo* info, int32 codepoint, int32* x0, int32* y0, int32* x1, int32* y1)
		{
			return stbtt_GetGlyphBox(info, stbtt_FindGlyphIndex(info, codepoint), x0, y0, x1, y1);
		}

		public static bool stbtt_IsGlyphEmpty(stbtt_fontinfo* info, int32 glyph_index)
		{
			stbtt_int16 numberOfContours;
			int32 g;
			if (info.cff.size != 0)
				return stbtt__GetGlyphInfoT2(info, glyph_index, null, null, null, null) == 0;
			g = stbtt__GetGlyfOffset(info, glyph_index);
			if (g < 0) return true;
			numberOfContours = ttSHORT(info.data + g);
			return numberOfContours == 0;
		}

		static int32 stbtt__close_shape(stbtt_vertex* vertices, int32 num_vertices, bool was_off, bool start_off,
			stbtt_int32 sx, stbtt_int32 sy, stbtt_int32 scx, stbtt_int32 scy, stbtt_int32 cx, stbtt_int32 cy)
		{
			var num_vertices;

			if (start_off)
			{
				if (was_off)
					stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, (cx + scx) >> 1, (cy + scy) >> 1, cx, cy);
				stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, sx, sy, scx, scy);
			} else {
				if (was_off)
					stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, sx, sy, cx, cy);
				else
					stbtt_setvertex(&vertices[num_vertices++], STBTT_vline, sx, sy, 0, 0);
			}
			return num_vertices;
		}

		static int32 stbtt__GetGlyphShapeTT(stbtt_fontinfo* info, int32 glyph_index, stbtt_vertex** pvertices)
		{
			stbtt_int16 numberOfContours;
			stbtt_uint8* endPtsOfContours;
			stbtt_uint8* data = info.data;
			stbtt_vertex* vertices = null;
			int32 num_vertices = 0;
			int32 g = stbtt__GetGlyfOffset(info, glyph_index);

			*pvertices = null;

			if (g < 0) return 0;

			numberOfContours = ttSHORT(data + g);

			if (numberOfContours > 0)
			{
				stbtt_uint8 flags = 0, flagcount;
				stbtt_int32 ins, i, j = 0, m, n, next_move, off;
				bool was_off = false, start_off = false;
				stbtt_int32 x, y, cx, cy, sx, sy, scx, scy;
				stbtt_uint8* points;
				endPtsOfContours = (data + g + 10);
				ins = ttUSHORT(data + g + 10 + numberOfContours * 2);
				points = data + g + 10 + numberOfContours * 2 + 2 + ins;

				n = 1 + ttUSHORT(endPtsOfContours + numberOfContours * 2 - 2);

				m = n + 2 * numberOfContours;// a loose bound on how many vertices we might need
				vertices = (stbtt_vertex*)STBTT_malloc!(m * sizeof(stbtt_vertex), info.userdata);
				if (vertices == null)
					return 0;

				next_move = 0;
				flagcount = 0;

				// in first pass, we load uninterpreted data into the allocated array
				// above, shifted to the end of the array so we won't overwrite it when
				// we create our final data starting from the front

				off = m - n;// starting offset for uninterpreted data, regardless of how m ends up being calculated

				// first load flags

				for (i = 0; i < n; ++i)
				{
					if (flagcount == 0)
					{
						flags = *points++;
						if ((flags & 8) != 0)
							flagcount = *points++;
					} else
						--flagcount;
					vertices[off + i].type = flags;
				}

				// now load x coordinates
				x = 0;
				for (i = 0; i < n; ++i)
				{
					flags = vertices[off + i].type;
					if ((flags & 2) != 0)
					{
						stbtt_int16 dx = *points++;
						x += ((flags & 16) != 0) ? dx : -dx;// ???
					} else {
						if ((flags & 16) == 0)
						{
							x = x + (stbtt_int16)((int32)points[0] * 256 + points[1]);
							points += 2;
						}
					}
					vertices[off + i].x = (stbtt_int16)x;
				}

				// now load y coordinates
				y = 0;
				for (i = 0; i < n; ++i)
				{
					flags = vertices[off + i].type;
					if ((flags & 4) != 0)
					{
						stbtt_int16 dy = *points++;
						y += ((flags & 32) != 0) ? dy : -dy;// ???
					} else {
						if ((flags & 32) == 0)
						{
							y = y + (stbtt_int16)((int32)points[0] * 256 + points[1]);
							points += 2;
						}
					}
					vertices[off + i].y = (stbtt_int16)y;
				}

				// now convert them to our format
				num_vertices = 0;
				sx = sy = cx = cy = scx = scy = 0;
				for (i = 0; i < n; ++i)
				{
					flags = vertices[off + i].type;
					x = (stbtt_int16)vertices[off + i].x;
					y = (stbtt_int16)vertices[off + i].y;

					if (next_move == i)
					{
						if (i != 0)
							num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx, sy, scx, scy, cx, cy);

						// now start the new one
						start_off = (flags & 1) == 0;
						if (start_off)
						{
						   // if we start off with an off-curve point, then when we need to find a point on the curve
						   // where we can start, and we need to save some state for when we wraparound.
							scx = x;
							scy = y;
							if ((vertices[off + i + 1].type & 1) == 0)
							{
							  // next point is also a curve point, so interpolate an on-point curve
								sx = (x + (stbtt_int32)vertices[off + i + 1].x) >> 1;
								sy = (y + (stbtt_int32)vertices[off + i + 1].y) >> 1;
							} else {
							  // otherwise just use the next point as our start point
								sx = (stbtt_int32)vertices[off + i + 1].x;
								sy = (stbtt_int32)vertices[off + i + 1].y;
								++i;// we're using point i+1 as the starting point, so skip it
							}
						} else {
							sx = x;
							sy = y;
						}
						stbtt_setvertex(&vertices[num_vertices++], STBTT_vmove, sx, sy, 0, 0);
						was_off = false;
						next_move = 1 + (int32)ttUSHORT(endPtsOfContours + j * 2);
						++j;
					} else {
						if ((flags & 1) == 0)
						{ // if it's a curve
							if (was_off)// two off-curve control points in a row means interpolate an on-curve midpoint
								stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, (cx + x) >> 1, (cy + y) >> 1, cx, cy);
							cx = x;
							cy = y;
							was_off = true;
						} else {
							if (was_off)
								stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, x, y, cx, cy);
							else
								stbtt_setvertex(&vertices[num_vertices++], STBTT_vline, x, y, 0, 0);
							was_off = false;
						}
					}
				}
				num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx, sy, scx, scy, cx, cy);
			} else if (numberOfContours < 0) {
			   // Compound shapes.
				int32 more = 1;
				stbtt_uint8* comp = data + g + 10;
				num_vertices = 0;
				vertices = null;
				while (more != 0)
				{
					stbtt_uint16 flags, gidx;
					int32 comp_num_verts = 0, i;
					stbtt_vertex* comp_verts = null, tmp = null;
					float[6] mtx = .(1, 0, 0, 1, 0, 0);
					float m, n;

					flags = (.)ttSHORT(comp); comp += 2;
					gidx = (.)ttSHORT(comp); comp += 2;

					if ((flags & 2) != 0)
					{ // XY values
						if ((flags & 1) != 0)
						{ // shorts
							mtx[4] = ttSHORT(comp); comp += 2;
							mtx[5] = ttSHORT(comp); comp += 2;
						} else {
							mtx[4] = ttCHAR!(comp); comp += 1;
							mtx[5] = ttCHAR!(comp); comp += 1;
						}
					}
					else {
					   // @TODO handle matching point
						STBTT_assert!(false);
					}
					if ((flags & (1 << 3)) != 0)
					{ // WE_HAVE_A_SCALE
						mtx[0] = mtx[3] = (float)ttSHORT(comp) / 16384.0f; comp += 2;
						mtx[1] = mtx[2] = 0;
					} else if ((flags & (1 << 6)) != 0) { // WE_HAVE_AN_X_AND_YSCALE
						mtx[0] = (float)ttSHORT(comp) / 16384.0f; comp += 2;
						mtx[1] = mtx[2] = 0;
						mtx[3] = (float)ttSHORT(comp) / 16384.0f; comp += 2;
					} else if ((flags & (1 << 7)) != 0) { // WE_HAVE_A_TWO_BY_TWO
						mtx[0] = (float)ttSHORT(comp) / 16384.0f; comp += 2;
						mtx[1] = (float)ttSHORT(comp) / 16384.0f; comp += 2;
						mtx[2] = (float)ttSHORT(comp) / 16384.0f; comp += 2;
						mtx[3] = (float)ttSHORT(comp) / 16384.0f; comp += 2;
					}

					// Find transformation scales.
					m = (float)STBTT_sqrt!(mtx[0] * mtx[0] + mtx[1] * mtx[1]);
					n = (float)STBTT_sqrt!(mtx[2] * mtx[2] + mtx[3] * mtx[3]);

					// Get indexed glyph.
					comp_num_verts = stbtt_GetGlyphShape(info, gidx, &comp_verts);
					if (comp_num_verts > 0)
					{
					   // Transform vertices.
						for (i = 0; i < comp_num_verts; ++i)
						{
							stbtt_vertex* v = &comp_verts[i];
							stbtt_vertex_type x, y;
							x = v.x; y = v.y;
							v.x = (stbtt_vertex_type)(m * (mtx[0] * x + mtx[2] * y + mtx[4]));
							v.y = (stbtt_vertex_type)(n * (mtx[1] * x + mtx[3] * y + mtx[5]));
							x = v.cx; y = v.cy;
							v.cx = (stbtt_vertex_type)(m * (mtx[0] * x + mtx[2] * y + mtx[4]));
							v.cy = (stbtt_vertex_type)(n * (mtx[1] * x + mtx[3] * y + mtx[5]));
						}
					   // Append vertices.
						tmp = (stbtt_vertex*)STBTT_malloc!((num_vertices + comp_num_verts) * sizeof(stbtt_vertex), info.userdata);
						if (tmp == null)
						{
							if (vertices != null) STBTT_free!(vertices, info.userdata);
							if (comp_verts != null) STBTT_free!(comp_verts, info.userdata);
							return 0;
						}
						if (num_vertices > 0 && vertices != null) STBTT_memcpy!(tmp, vertices, num_vertices * sizeof(stbtt_vertex));
						STBTT_memcpy!(tmp + num_vertices, comp_verts, comp_num_verts * sizeof(stbtt_vertex));
						if (vertices != null) STBTT_free!(vertices, info.userdata);
						vertices = tmp;
						STBTT_free!(comp_verts, info.userdata);
						num_vertices += comp_num_verts;
					}
					// More components ?
					more = flags & (1 << 5);
				}
			} else {
			   // numberOfCounters == 0, do nothing
			}

			*pvertices = vertices;
			return num_vertices;
		}

		struct stbtt__csctx
		{
			public int32 bounds;
			public bool started;
			public float first_x, first_y;
			public float x, y;
			public stbtt_int32 min_x, max_x, min_y, max_y;

			public stbtt_vertex* pvertices;
			public int32 num_vertices;
		}

		static mixin STBTT__CSCTX_INIT(var bounds)
		{
			stbtt__csctx a = default;
			a.bounds = bounds;
			a
		}

		static void stbtt__track_vertex(stbtt__csctx* c, stbtt_int32 x, stbtt_int32 y)
		{
			if (x > c.max_x || !c.started) c.max_x = x;
			if (y > c.max_y || !c.started) c.max_y = y;
			if (x < c.min_x || !c.started) c.min_x = x;
			if (y < c.min_y || !c.started) c.min_y = y;
			c.started = true;
		}

		static void stbtt__csctx_v(stbtt__csctx* c, stbtt_uint8 type, stbtt_int32 x, stbtt_int32 y, stbtt_int32 cx, stbtt_int32 cy, stbtt_int32 cx1, stbtt_int32 cy1)
		{
			if (c.bounds != 0)
			{
				stbtt__track_vertex(c, x, y);
				if (type == STBTT_vcubic)
				{
					stbtt__track_vertex(c, cx, cy);
					stbtt__track_vertex(c, cx1, cy1);
				}
			} else {
				stbtt_setvertex(&c.pvertices[c.num_vertices], type, x, y, cx, cy);
				c.pvertices[c.num_vertices].cx1 = (stbtt_int16)cx1;
				c.pvertices[c.num_vertices].cy1 = (stbtt_int16)cy1;
			}
			c.num_vertices++;
		}

		static void stbtt__csctx_close_shape(stbtt__csctx* ctx)
		{
			if (ctx.first_x != ctx.x || ctx.first_y != ctx.y)
				stbtt__csctx_v(ctx, STBTT_vline, (int32)ctx.first_x, (int32)ctx.first_y, 0, 0, 0, 0);
		}

		static void stbtt__csctx_rmove_to(stbtt__csctx* ctx, float dx, float dy)
		{
			stbtt__csctx_close_shape(ctx);
			ctx.first_x = ctx.x = ctx.x + dx;
			ctx.first_y = ctx.y = ctx.y + dy;
			stbtt__csctx_v(ctx, STBTT_vmove, (int32)ctx.x, (int32)ctx.y, 0, 0, 0, 0);
		}

		static void stbtt__csctx_rline_to(stbtt__csctx* ctx, float dx, float dy)
		{
			ctx.x += dx;
			ctx.y += dy;
			stbtt__csctx_v(ctx, STBTT_vline, (int32)ctx.x, (int32)ctx.y, 0, 0, 0, 0);
		}

		static void stbtt__csctx_rccurve_to(stbtt__csctx* ctx, float dx1, float dy1, float dx2, float dy2, float dx3, float dy3)
		{
			float cx1 = ctx.x + dx1;
			float cy1 = ctx.y + dy1;
			float cx2 = cx1 + dx2;
			float cy2 = cy1 + dy2;
			ctx.x = cx2 + dx3;
			ctx.y = cy2 + dy3;
			stbtt__csctx_v(ctx, STBTT_vcubic, (int32)ctx.x, (int32)ctx.y, (int32)cx1, (int32)cy1, (int32)cx2, (int32)cy2);
		}

		static stbtt__buf stbtt__get_subr(stbtt__buf idx, int32 n)
		{
			var idx, n;

			int32 count = stbtt__cff_index_count(&idx);
			int32 bias = 107;
			if (count >= 33900)
				bias = 32768;
			else if (count >= 1240)
				bias = 1131;
			n += bias;
			if (n < 0 || n >= count)
				return stbtt__new_buf(null, 0);
			return stbtt__cff_index_get(idx, n);
		}

		static stbtt__buf stbtt__cid_get_glyph_subrs(stbtt_fontinfo* info, int32 glyph_index)
		{
			stbtt__buf fdselect = info.fdselect;
			int32 nranges, start, end, v, fmt, fdselector = -1, i;

			stbtt__buf_seek(&fdselect, 0);
			fmt = stbtt__buf_get8(&fdselect);
			if (fmt == 0)
			{
			   // untested
				stbtt__buf_skip(&fdselect, glyph_index);
				fdselector = stbtt__buf_get8(&fdselect);
			} else if (fmt == 3) {
				nranges = (.)stbtt__buf_get16(&fdselect);
				start = (.)stbtt__buf_get16(&fdselect);
				for (i = 0; i < nranges; i++)
				{
					v = stbtt__buf_get8(&fdselect);
					end = (.)stbtt__buf_get16(&fdselect);
					if (glyph_index >= start && glyph_index < end)
					{
						fdselector = v;
						break;
					}
					start = end;
				}
			}
			if (fdselector == -1) stbtt__new_buf(null, 0);
			return stbtt__get_subrs(info.cff, stbtt__cff_index_get(info.fontdicts, fdselector));
		}

		static bool stbtt__run_charstring(stbtt_fontinfo* info, int32 glyph_index, stbtt__csctx* c)
		{
			mixin STBTT__CSERR(char8* s)
			{
				false
			}

			bool in_header = true, has_subrs = false, clear_stack;
			int32 maskbits = 0, subr_stack_height = 0, sp = 0, v, i, b0;
			float[48] s = default;
			stbtt__buf[10] subr_stack = default;
			stbtt__buf subrs = info.subrs, b;
			float f;

		   // this currently ignores the initial width value, which isn't needed if we have hmtx
			b = stbtt__cff_index_get(info.charstrings, glyph_index);
			while (b.cursor < b.size)
			{
				i = 0;
				clear_stack = true;
				b0 = stbtt__buf_get8(&b);
				switch (b0) {
				// @TODO implement hinting
				case 0x13: fallthrough;// hintmask
				case 0x14:// cntrmask
					if (in_header)
						maskbits += (sp / 2);// implicit "vstem"
					in_header = false;
					stbtt__buf_skip(&b, (maskbits + 7) / 8);
					break;

				case 0x01: fallthrough;// hstem
				case 0x03: fallthrough;// vstem
				case 0x12: fallthrough;// hstemhm
				case 0x17:// vstemhm
					maskbits += (sp / 2);
					break;

				case 0x15:// rmoveto
					in_header = false;
					if (sp < 2) return STBTT__CSERR!("rmoveto stack");
					stbtt__csctx_rmove_to(c, s[sp - 2], s[sp - 1]);
					break;
				case 0x04:// vmoveto
					in_header = false;
					if (sp < 1) return STBTT__CSERR!("vmoveto stack");
					stbtt__csctx_rmove_to(c, 0, s[sp - 1]);
					break;
				case 0x16:// hmoveto
					in_header = false;
					if (sp < 1) return STBTT__CSERR!("hmoveto stack");
					stbtt__csctx_rmove_to(c, s[sp - 1], 0);
					break;

				case 0x05:// rlineto
					if (sp < 2) return STBTT__CSERR!("rlineto stack");
					for (; i + 1 < sp; i += 2)
						stbtt__csctx_rline_to(c, s[i], s[i + 1]);
					break;

				// hlineto/vlineto and vhcurveto/hvcurveto alternate horizontal and vertical
				// starting from a different place.

				case 0x07:// vlineto
					if (sp < 1) return STBTT__CSERR!("vlineto stack");

					//goto vlineto;
					fallthrough;
				case 0x06:// hlineto
					if (sp < 1) return STBTT__CSERR!("hlineto stack");

					bool skipH = b0 == 0x07;
					for (;;)
					{
						if (!skipH)
						{
							if (i >= sp) break;
							stbtt__csctx_rline_to(c, s[i], 0);
							i++;
						}
						else skipH = false;

				//vlineto:
						if (i >= sp) break;
						stbtt__csctx_rline_to(c, 0, s[i]);
						i++;
					}
					break;

				case 0x1F:// hvcurveto
					if (sp < 4) return STBTT__CSERR!("hvcurveto stack");
					//goto hvcurveto;
					fallthrough;
				case 0x1E:// vhcurveto
					if (sp < 4) return STBTT__CSERR!("vhcurveto stack");

					bool skipH = b0 == 0x1F;
					for (;;)
					{
						if (!skipH)
						{
							if (i + 3 >= sp) break;
							stbtt__csctx_rccurve_to(c, 0, s[i], s[i + 1], s[i + 2], s[i + 3], (sp - i == 5) ? s[i + 4] : 0.0f);
							i += 4;
						}
						else skipH = false;

					// hvcurveto:
						if (i + 3 >= sp) break;
						stbtt__csctx_rccurve_to(c, s[i], 0, s[i + 1], s[i + 2], (sp - i == 5) ? s[i + 4] : 0.0f, s[i + 3]);
						i += 4;
					}
					break;

				case 0x08:// rrcurveto
					if (sp < 6) return STBTT__CSERR!("rcurveline stack");
					for (; i + 5 < sp; i += 6)
						stbtt__csctx_rccurve_to(c, s[i], s[i + 1], s[i + 2], s[i + 3], s[i + 4], s[i + 5]);
					break;

				case 0x18:// rcurveline
					if (sp < 8) return STBTT__CSERR!("rcurveline stack");
					for (; i + 5 < sp - 2; i += 6)
						stbtt__csctx_rccurve_to(c, s[i], s[i + 1], s[i + 2], s[i + 3], s[i + 4], s[i + 5]);
					if (i + 1 >= sp) return STBTT__CSERR!("rcurveline stack");
					stbtt__csctx_rline_to(c, s[i], s[i + 1]);
					break;

				case 0x19:// rlinecurve
					if (sp < 8) return STBTT__CSERR!("rlinecurve stack");
					for (; i + 1 < sp - 6; i += 2)
						stbtt__csctx_rline_to(c, s[i], s[i + 1]);
					if (i + 5 >= sp) return STBTT__CSERR!("rlinecurve stack");
					stbtt__csctx_rccurve_to(c, s[i], s[i + 1], s[i + 2], s[i + 3], s[i + 4], s[i + 5]);
					break;

				case 0x1A: fallthrough;// vvcurveto
				case 0x1B:// hhcurveto
					if (sp < 4) return STBTT__CSERR!("(vv|hh)curveto stack");
					f = 0.0f;
					if ((sp & 1) != 0) { f = s[i]; i++; }
					for (; i + 3 < sp; i += 4)
					{
						if (b0 == 0x1B)
							stbtt__csctx_rccurve_to(c, s[i], f, s[i + 1], s[i + 2], s[i + 3], 0.0f);
						else
							stbtt__csctx_rccurve_to(c, f, s[i], s[i + 1], s[i + 2], 0.0f, s[i + 3]);
						f = 0.0f;
					}
					break;

				case 0x0A:// callsubr
					if (!has_subrs)
					{
						if (info.fdselect.size != 0)
							subrs = stbtt__cid_get_glyph_subrs(info, glyph_index);
						has_subrs = true;
					}
				   // FALLTHROUGH
					fallthrough;

				case 0x1D:// callgsubr
					if (sp < 1) return STBTT__CSERR!("call(g|)subr stack");
					v = (int32)s[--sp];
					if (subr_stack_height >= 10) return STBTT__CSERR!("recursion limit");
					subr_stack[subr_stack_height++] = b;
					b = stbtt__get_subr(b0 == 0x0A ? subrs : info.gsubrs, v);
					if (b.size == 0) return STBTT__CSERR!("subr not found");
					b.cursor = 0;
					clear_stack = false;
					break;

				case 0x0B:// return
					if (subr_stack_height <= 0) return STBTT__CSERR!("return outside subr");
					b = subr_stack[--subr_stack_height];
					clear_stack = false;
					break;

				case 0x0E:// endchar
					stbtt__csctx_close_shape(c);
					return true;

				case 0x0C:
					{ // two-byte escape
						float dx1, dx2, dx3, dx4, dx5, dx6, dy1, dy2, dy3, dy4, dy5, dy6;
						float dx = 0, dy = 0;
						int32 b1 = stbtt__buf_get8(&b);
						switch (b1) {
							// @TODO These "flex" implementations ignore the flex-depth and resolution,
							// and always draw beziers.
						case 0x22:// hflex
							if (sp < 7) return STBTT__CSERR!("hflex stack");
							dx1 = s[0];
							dx2 = s[1];
							dy2 = s[2];
							dx3 = s[3];
							dx4 = s[4];
							dx5 = s[5];
							dx6 = s[6];
							stbtt__csctx_rccurve_to(c, dx1, 0, dx2, dy2, dx3, 0);
							stbtt__csctx_rccurve_to(c, dx4, 0, dx5, -dy2, dx6, 0);
							break;

						case 0x23:// flex
							if (sp < 13) return STBTT__CSERR!("flex stack");
							dx1 = s[0];
							dy1 = s[1];
							dx2 = s[2];
							dy2 = s[3];
							dx3 = s[4];
							dy3 = s[5];
							dx4 = s[6];
							dy4 = s[7];
							dx5 = s[8];
							dy5 = s[9];
							dx6 = s[10];
							dy6 = s[11];
					  //fd is s[12]
							stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
							stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
							break;

						case 0x24:// hflex1
							if (sp < 9) return STBTT__CSERR!("hflex1 stack");
							dx1 = s[0];
							dy1 = s[1];
							dx2 = s[2];
							dy2 = s[3];
							dx3 = s[4];
							dx4 = s[5];
							dx5 = s[6];
							dy5 = s[7];
							dx6 = s[8];
							stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, 0);
							stbtt__csctx_rccurve_to(c, dx4, 0, dx5, dy5, dx6, -(dy1 + dy2 + dy5));
							break;

						case 0x25:// flex1
							if (sp < 11) return STBTT__CSERR!("flex1 stack");
							dx1 = s[0];
							dy1 = s[1];
							dx2 = s[2];
							dy2 = s[3];
							dx3 = s[4];
							dy3 = s[5];
							dx4 = s[6];
							dy4 = s[7];
							dx5 = s[8];
							dy5 = s[9];
							dx6 = dy6 = s[10];
							dx = dx1 + dx2 + dx3 + dx4 + dx5;
							dy = dy1 + dy2 + dy3 + dy4 + dy5;
							if (STBTT_fabs!(dx) > STBTT_fabs!(dy))
								dy6 = -dy;
							else
								dx6 = -dx;
							stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
							stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
							break;

						default:
							return STBTT__CSERR!("unimplemented");
						}
					} break;

				default:
					if (b0 != 255 && b0 != 28 && b0 < 32)
						return STBTT__CSERR!("reserved operator");

				   // push immediate
					if (b0 == 255)
					{
						f = (float)(stbtt_int32)stbtt__buf_get32(&b) / 0x10000;
					} else {
						stbtt__buf_skip(&b, -1);
						f = (float)(stbtt_int16)stbtt__cff_int(&b);
					}
					if (sp >= 48) return STBTT__CSERR!("push stack overflow");
					s[sp++] = f;
					clear_stack = false;
					break;
				}
				if (clear_stack) sp = 0;
			}
			return STBTT__CSERR!("no endchar");
		}

		static int32 stbtt__GetGlyphShapeT2(stbtt_fontinfo* info, int32 glyph_index, stbtt_vertex** pvertices)
		{
		   // runs the charstring twice, once to count and once to output (to avoid realloc)
			stbtt__csctx count_ctx = STBTT__CSCTX_INIT!(1);
			stbtt__csctx output_ctx = STBTT__CSCTX_INIT!(0);
			if (stbtt__run_charstring(info, glyph_index, &count_ctx))
			{
				*pvertices = (stbtt_vertex*)STBTT_malloc!(count_ctx.num_vertices * sizeof(stbtt_vertex), info.userdata);
				output_ctx.pvertices = *pvertices;
				if (stbtt__run_charstring(info, glyph_index, &output_ctx))
				{
					STBTT_assert!(output_ctx.num_vertices == count_ctx.num_vertices);
					return output_ctx.num_vertices;
				}
			}
			*pvertices = null;
			return 0;
		}

		static int32 stbtt__GetGlyphInfoT2(stbtt_fontinfo* info, int32 glyph_index, int32* x0, int32* y0, int32* x1, int32* y1)
		{
			stbtt__csctx c = STBTT__CSCTX_INIT!(1);
			bool r = stbtt__run_charstring(info, glyph_index, &c);
			if (x0 != null) *x0 = r ? c.min_x : 0;
			if (y0 != null) *y0 = r ? c.min_y : 0;
			if (x1 != null) *x1 = r ? c.max_x : 0;
			if (y1 != null) *y1 = r ? c.max_y : 0;
			return r ? c.num_vertices : 0;
		}

		public static int32 stbtt_GetGlyphShape(stbtt_fontinfo* info, int32 glyph_index, stbtt_vertex** pvertices)
		{
			if (info.cff.size == 0)
				return stbtt__GetGlyphShapeTT(info, glyph_index, pvertices);
			else
				return stbtt__GetGlyphShapeT2(info, glyph_index, pvertices);
		}

		public static void stbtt_GetGlyphHMetrics(stbtt_fontinfo* info, int32 glyph_index, int32* advanceWidth, int32* leftSideBearing)
		{
			stbtt_uint16 numOfLongHorMetrics = ttUSHORT(info.data + info.hhea + 34);
			if (glyph_index < numOfLongHorMetrics)
			{
				if (advanceWidth != null) *advanceWidth = ttSHORT(info.data + info.hmtx + 4 * glyph_index);
				if (leftSideBearing != null) *leftSideBearing = ttSHORT(info.data + info.hmtx + 4 * glyph_index + 2);
			} else
			{
				if (advanceWidth != null) *advanceWidth = ttSHORT(info.data + info.hmtx + 4 * ((int32)numOfLongHorMetrics - 1));
				if (leftSideBearing != null) *leftSideBearing = ttSHORT(info.data + info.hmtx + 4 * (int32)numOfLongHorMetrics + 2 * (glyph_index - numOfLongHorMetrics));
			}
		}

		public static int32 stbtt_GetKerningTableLength(stbtt_fontinfo* info)
		{
			stbtt_uint8* data = info.data + info.kern;

			// we only look at the first table. it must be 'horizontal' and format 0.
			if (info.kern == 0)
				return 0;
			if (ttUSHORT(data + 2) < 1)// number of tables, need at least 1
				return 0;
			if (ttUSHORT(data + 8) != 1)// horizontal flag must be set in format
				return 0;

			return ttUSHORT(data + 10);
		}

		public static int32 stbtt_GetKerningTable(stbtt_fontinfo* info, stbtt_kerningentry* table, int32 table_length)
		{
			stbtt_uint8* data = info.data + info.kern;
			int32 k, length;

			// we only look at the first table. it must be 'horizontal' and format 0.
			if (info.kern == 0)
				return 0;
			if (ttUSHORT(data + 2) < 1)// number of tables, need at least 1
				return 0;
			if (ttUSHORT(data + 8) != 1)// horizontal flag must be set in format
				return 0;

			length = ttUSHORT(data + 10);
			if (table_length < length)
				length = table_length;

			for (k = 0; k < length; k++)
			{
				table[k].glyph1 = ttUSHORT(data + 18 + (k * 6));
				table[k].glyph2 = ttUSHORT(data + 20 + (k * 6));
				table[k].advance = ttSHORT(data + 22 + (k * 6));
			}

			return length;
		}

		static int32 stbtt__GetGlyphKernInfoAdvance(stbtt_fontinfo* info, int32 glyph1, int32 glyph2)
		{
			stbtt_uint8* data = info.data + info.kern;
			stbtt_uint32 needle, straw;
			int32 l, r, m;

			// we only look at the first table. it must be 'horizontal' and format 0.
			if (info.kern == 0)
				return 0;
			if (ttUSHORT(data + 2) < 1)// number of tables, need at least 1
				return 0;
			if (ttUSHORT(data + 8) != 1)// horizontal flag must be set in format
				return 0;

			l = 0;
			r = (int32)ttUSHORT(data + 10) - 1;
			needle = (.)glyph1 << 16 | (.)glyph2;
			while (l <= r)
			{
				m = (l + r) >> 1;
				straw = ttULONG(data + 18 + (m * 6));// note: unaligned read
				if (needle < straw)
					r = m - 1;
				else if (needle > straw)
					l = m + 1;
				else
					return ttSHORT(data + 22 + (m * 6));
			}
			return 0;
		}

		static stbtt_int32 stbtt__GetCoverageIndex(stbtt_uint8* coverageTable, int32 glyph)
		{
			stbtt_uint16 coverageFormat = ttUSHORT(coverageTable);
			switch (coverageFormat) {
			case 1:
				{
					stbtt_uint16 glyphCount = ttUSHORT(coverageTable + 2);

					// Binary search.
					stbtt_int32 l = 0, r = (int32)glyphCount - 1, m;
					int32 straw, needle = glyph;
					while (l <= r)
					{
						stbtt_uint8* glyphArray = coverageTable + 4;
						stbtt_uint16 glyphID;
						m = (l + r) >> 1;
						glyphID = ttUSHORT(glyphArray + 2 * m);
						straw = glyphID;
						if (needle < straw)
							r = m - 1;
						else if (needle > straw)
							l = m + 1;
						else
						{
							return m;
						}
					}
					break;
				}

			case 2:
				{
					stbtt_uint16 rangeCount = ttUSHORT(coverageTable + 2);
					stbtt_uint8* rangeArray = coverageTable + 4;

					// Binary search.
					stbtt_int32 l = 0, r = (int32)rangeCount - 1, m;
					int32 strawStart, strawEnd, needle = glyph;
					while (l <= r)
					{
						stbtt_uint8* rangeRecord;
						m = (l + r) >> 1;
						rangeRecord = rangeArray + 6 * m;
						strawStart = ttUSHORT(rangeRecord);
						strawEnd = ttUSHORT(rangeRecord + 2);
						if (needle < strawStart)
							r = m - 1;
						else if (needle > strawEnd)
							l = m + 1;
						else
						{
							stbtt_uint16 startCoverageIndex = ttUSHORT(rangeRecord + 4);
							return (int32)startCoverageIndex + glyph - strawStart;
						}
					}
					break;
				}

			default: return -1;// unsupported
			}

			return -1;
		}

		static stbtt_int32 stbtt__GetGlyphClass(stbtt_uint8* classDefTable, int32 glyph)
		{
			stbtt_uint16 classDefFormat = ttUSHORT(classDefTable);
			switch (classDefFormat)
			{
			case 1:
				{
					stbtt_uint16 startGlyphID = ttUSHORT(classDefTable + 2);
					stbtt_uint16 glyphCount = ttUSHORT(classDefTable + 4);
					stbtt_uint8* classDef1ValueArray = classDefTable + 6;

					if (glyph >= startGlyphID && glyph < (int32)startGlyphID + glyphCount)
						return (stbtt_int32)ttUSHORT(classDef1ValueArray + 2 * (glyph - startGlyphID));
					break;
				}

			case 2:
				{
					stbtt_uint16 classRangeCount = ttUSHORT(classDefTable + 2);
					stbtt_uint8* classRangeRecords = classDefTable + 4;

					// Binary search.
					stbtt_int32 l = 0, r = (int32)classRangeCount - 1, m;
					int32 strawStart, strawEnd, needle = glyph;
					while (l <= r)
					{
						stbtt_uint8* classRangeRecord;
						m = (l + r) >> 1;
						classRangeRecord = classRangeRecords + 6 * m;
						strawStart = ttUSHORT(classRangeRecord);
						strawEnd = ttUSHORT(classRangeRecord + 2);
						if (needle < strawStart)
							r = m - 1;
						else if (needle > strawEnd)
							l = m + 1;
						else
							return (stbtt_int32)ttUSHORT(classRangeRecord + 4);
					}
					break;
				}

			default:
				return -1;// Unsupported definition type, return an error.
			}

			// "All glyphs not assigned to a class fall into class 0". (OpenType spec)
			return 0;
		}

		 // Define to STBTT_assert!(x) if you want to break on unimplemented formats.
 //#define STBTT_GPOS_TODO_assert(x)

		static stbtt_int32 stbtt__GetGlyphGPOSInfoAdvance(stbtt_fontinfo* info, int32 glyph1, int32 glyph2)
		{
			stbtt_uint16 lookupListOffset;
			stbtt_uint8* lookupList;
			stbtt_uint16 lookupCount;
			stbtt_uint8* data;
			stbtt_int32 i, sti;

			if (info.gpos == 0) return 0;

			data = info.data + info.gpos;

			if (ttUSHORT(data + 0) != 1) return 0;// Major version 1
			if (ttUSHORT(data + 2) != 0) return 0;// Minor version 0

			lookupListOffset = ttUSHORT(data + 8);
			lookupList = data + lookupListOffset;
			lookupCount = ttUSHORT(lookupList);

			for (i = 0; i < (int32)lookupCount; ++i)
			{
				stbtt_uint16 lookupOffset = ttUSHORT(lookupList + 2 + 2 * i);
				stbtt_uint8* lookupTable = lookupList + lookupOffset;

				stbtt_uint16 lookupType = ttUSHORT(lookupTable);
				stbtt_uint16 subTableCount = ttUSHORT(lookupTable + 4);
				stbtt_uint8* subTableOffsets = lookupTable + 6;
				if (lookupType != 2)// Pair Adjustment Positioning Subtable
					continue;

				for (sti = 0; sti < (int32)subTableCount; sti++)
				{
					stbtt_uint16 subtableOffset = ttUSHORT(subTableOffsets + 2 * sti);
					stbtt_uint8* table = lookupTable + subtableOffset;
					stbtt_uint16 posFormat = ttUSHORT(table);
					stbtt_uint16 coverageOffset = ttUSHORT(table + 2);
					stbtt_int32 coverageIndex = stbtt__GetCoverageIndex(table + coverageOffset, glyph1);
					if (coverageIndex == -1) continue;

					switch (posFormat) {
					case 1:
						{
							stbtt_int32 l, r, m;
							int32 straw, needle;
							stbtt_uint16 valueFormat1 = ttUSHORT(table + 4);
							stbtt_uint16 valueFormat2 = ttUSHORT(table + 6);
							if (valueFormat1 == 4 && valueFormat2 == 0)
							{// Support more formats?
								stbtt_int32 valueRecordPairSizeInBytes = 2;
								stbtt_uint16 pairSetCount = ttUSHORT(table + 8);
								stbtt_uint16 pairPosOffset = ttUSHORT(table + 10 + 2 * coverageIndex);
								stbtt_uint8* pairValueTable = table + pairPosOffset;
								stbtt_uint16 pairValueCount = ttUSHORT(pairValueTable);
								stbtt_uint8* pairValueArray = pairValueTable + 2;

								if (coverageIndex >= pairSetCount) return 0;

								needle = glyph2;
								r = (int32)pairValueCount - 1;
								l = 0;

							   // Binary search.
								while (l <= r)
								{
									stbtt_uint16 secondGlyph;
									stbtt_uint8* pairValue;
									m = (l + r) >> 1;
									pairValue = pairValueArray + (2 + valueRecordPairSizeInBytes) * m;
									secondGlyph = ttUSHORT(pairValue);
									straw = secondGlyph;
									if (needle < straw)
										r = m - 1;
									else if (needle > straw)
										l = m + 1;
									else
									{
										stbtt_int16 xAdvance = ttSHORT(pairValue + 2);
										return xAdvance;
									}
								}
							} else
								return 0;
							break;
						}

					case 2:
						{
							stbtt_uint16 valueFormat1 = ttUSHORT(table + 4);
							stbtt_uint16 valueFormat2 = ttUSHORT(table + 6);
							if (valueFormat1 == 4 && valueFormat2 == 0)
							{// Support more formats?
								stbtt_uint16 classDef1Offset = ttUSHORT(table + 8);
								stbtt_uint16 classDef2Offset = ttUSHORT(table + 10);
								int32 glyph1class = stbtt__GetGlyphClass(table + classDef1Offset, glyph1);
								int32 glyph2class = stbtt__GetGlyphClass(table + classDef2Offset, glyph2);

								stbtt_uint16 class1Count = ttUSHORT(table + 12);
								stbtt_uint16 class2Count = ttUSHORT(table + 14);
								stbtt_uint8* class1Records, class2Records;
								stbtt_int16 xAdvance;

								if (glyph1class < 0 || glyph1class >= class1Count) return 0;// malformed
								if (glyph2class < 0 || glyph2class >= class2Count) return 0;// malformed

								class1Records = table + 16;
								class2Records = class1Records + 2 * (glyph1class * class2Count);
								xAdvance = ttSHORT(class2Records + 2 * glyph2class);
								return xAdvance;
							} else
								return 0;
							//break; // @PORT: unreachable
						}

					default:
						return 0;// Unsupported position format
					}
				}
			}

			return 0;
		}

		public static int32 stbtt_GetGlyphKernAdvance(stbtt_fontinfo* info, int32 g1, int32 g2)
		{
			int32 xAdvance = 0;

			if (info.gpos != 0)
				xAdvance += stbtt__GetGlyphGPOSInfoAdvance(info, g1, g2);
			else if (info.kern != 0)
				xAdvance += stbtt__GetGlyphKernInfoAdvance(info, g1, g2);

			return xAdvance;
		}

		public static int32 stbtt_GetCodepointKernAdvance(stbtt_fontinfo* info, int32 ch1, int32 ch2)
		{
			if (info.kern == 0 && info.gpos == 0)// if no kerning table, don't waste time looking up both
				// codepoint.glyphs
				return 0;
			return stbtt_GetGlyphKernAdvance(info, stbtt_FindGlyphIndex(info, ch1), stbtt_FindGlyphIndex(info, ch2));
		}

		public static void stbtt_GetCodepointHMetrics(stbtt_fontinfo* info, int32 codepoint, int32* advanceWidth, int32* leftSideBearing)
		{
			stbtt_GetGlyphHMetrics(info, stbtt_FindGlyphIndex(info, codepoint), advanceWidth, leftSideBearing);
		}

		public static void stbtt_GetFontVMetrics(stbtt_fontinfo* info, int32* ascent, int32* descent, int32* lineGap)
		{
			if (ascent != null) *ascent = ttSHORT(info.data + info.hhea + 4);
			if (descent != null) *descent = ttSHORT(info.data + info.hhea + 6);
			if (lineGap != null) *lineGap = ttSHORT(info.data + info.hhea + 8);
		}

		public static bool stbtt_GetFontVMetricsOS2(stbtt_fontinfo* info, int32* typoAscent, int32* typoDescent, int32* typoLineGap)
		{
			int32 tab = (.)stbtt__find_table(info.data, (.)info.fontstart, "OS/2");
			if (tab == 0)
				return false;
			if (typoAscent != null) *typoAscent = ttSHORT(info.data + tab + 68);
			if (typoDescent != null) *typoDescent = ttSHORT(info.data + tab + 70);
			if (typoLineGap != null) *typoLineGap = ttSHORT(info.data + tab + 72);
			return true;
		}

		public static void stbtt_GetFontBoundingBox(stbtt_fontinfo* info, int32* x0, int32* y0, int32* x1, int32* y1)
		{
			*x0 = ttSHORT(info.data + info.head + 36);
			*y0 = ttSHORT(info.data + info.head + 38);
			*x1 = ttSHORT(info.data + info.head + 40);
			*y1 = ttSHORT(info.data + info.head + 42);
		}

		public static float stbtt_ScaleForPixelHeight(stbtt_fontinfo* info, float height)
		{
			int32 fheight = (int32)ttSHORT(info.data + info.hhea + 4) - ttSHORT(info.data + info.hhea + 6);
			return (float)height / fheight;
		}

		public static float stbtt_ScaleForMappingEmToPixels(stbtt_fontinfo* info, float pixels)
		{
			int32 unitsPerEm = ttUSHORT(info.data + info.head + 18);
			return pixels / unitsPerEm;
		}

		public static void stbtt_FreeShape(stbtt_fontinfo* info, stbtt_vertex* v)
		{
			STBTT_free!(v, info.userdata);
		}

		public static stbtt_uint8* stbtt_FindSVGDoc(stbtt_fontinfo* info, int32 gl)
		{
			int32 i;
			stbtt_uint8* data = info.data;
			stbtt_uint8* svg_doc_list = data + stbtt__get_svg((stbtt_fontinfo*)info);

			int32 numEntries = ttUSHORT(svg_doc_list);
			stbtt_uint8* svg_docs = svg_doc_list + 2;

			for (i = 0; i < numEntries; i++)
			{
				stbtt_uint8* svg_doc = svg_docs + (12 * i);
				if ((gl >= ttUSHORT(svg_doc)) && (gl <= ttUSHORT(svg_doc + 2)))
					return svg_doc;
			}
			return null;
		}

		public static int32 stbtt_GetGlyphSVG(stbtt_fontinfo* info, int32 gl, char8** svg)
		{
			stbtt_uint8* data = info.data;
			stbtt_uint8* svg_doc;

			if (info.svg == 0)
				return 0;

			svg_doc = stbtt_FindSVGDoc(info, gl);
			if (svg_doc != null)
			{
				*svg = (char8*)data + info.svg + ttULONG(svg_doc + 4);
				return (.)ttULONG(svg_doc + 8);
			} else {
				return 0;
			}
		}

		public static int32 stbtt_GetCodepointSVG(stbtt_fontinfo* info, int32 unicode_codepoint, char8** svg)
		{
			return stbtt_GetGlyphSVG(info, stbtt_FindGlyphIndex(info, unicode_codepoint), svg);
		}

		 //////////////////////////////////////////////////////////////////////////////
		 //
		 // antialiasing software rasterizer
		 //

		public static void stbtt_GetGlyphBitmapBoxSubpixel(stbtt_fontinfo* font, int32 glyph, float scale_x, float scale_y, float shift_x, float shift_y, int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			int32 x0 = ?, y0 = ?, x1 = ?, y1 = ?;
			if (!stbtt_GetGlyphBox(font, glyph, &x0, &y0, &x1, &y1))
			{
			   // e.g. space character
				if (ix0 != null) *ix0 = 0;
				if (iy0 != null) *iy0 = 0;
				if (ix1 != null) *ix1 = 0;
				if (iy1 != null) *iy1 = 0;
			} else {
			   // move to integral bboxes (treating pixels as little squares, what pixels get touched)?
				if (ix0 != null) *ix0 = (int32)STBTT_ifloor!((double)x0 * scale_x + shift_x);
				if (iy0 != null) *iy0 = (int32)STBTT_ifloor!((double)(-y1) * scale_y + shift_y);
				if (ix1 != null) *ix1 = (int32)STBTT_iceil!((double)x1 * scale_x + shift_x);
				if (iy1 != null) *iy1 = (int32)STBTT_iceil!((double)(-y0) * scale_y + shift_y);
			}
		}

		public static void stbtt_GetGlyphBitmapBox(stbtt_fontinfo* font, int32 glyph, float scale_x, float scale_y, int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			stbtt_GetGlyphBitmapBoxSubpixel(font, glyph, scale_x, scale_y, 0.0f, 0.0f, ix0, iy0, ix1, iy1);
		}

		public static void stbtt_GetCodepointBitmapBoxSubpixel(stbtt_fontinfo* font, int32 codepoint, float scale_x, float scale_y, float shift_x, float shift_y, int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			stbtt_GetGlyphBitmapBoxSubpixel(font, stbtt_FindGlyphIndex(font, codepoint), scale_x, scale_y, shift_x, shift_y, ix0, iy0, ix1, iy1);
		}

		public static void stbtt_GetCodepointBitmapBox(stbtt_fontinfo* font, int32 codepoint, float scale_x, float scale_y, int32* ix0, int32* iy0, int32* ix1, int32* iy1)
		{
			stbtt_GetCodepointBitmapBoxSubpixel(font, codepoint, scale_x, scale_y, 0.0f, 0.0f, ix0, iy0, ix1, iy1);
		}

		 //////////////////////////////////////////////////////////////////////////////
		 //
		 //  Rasterizer

		struct stbtt__hheap_chunk
		{
			public stbtt__hheap_chunk* next;
		}

		struct stbtt__hheap
		{
			public stbtt__hheap_chunk* head;
			public void* first_free;
			public int32 num_remaining_in_head_chunk;
		}

		static void* stbtt__hheap_alloc(stbtt__hheap* hh, int size, void* userdata)
		{
			if (hh.first_free != null)
			{
				void* p = hh.first_free;
				hh.first_free = *(void**)p;
				return p;
			} else {
				if (hh.num_remaining_in_head_chunk == 0)
				{
					int32 count = (size < 32 ? 2000 : size < 128 ? 800 : 100);
					stbtt__hheap_chunk* c = (stbtt__hheap_chunk*)STBTT_malloc!(sizeof(stbtt__hheap_chunk) + size * count, userdata);
					if (c == null)
						return null;
					c.next = hh.head;
					hh.head = c;
					hh.num_remaining_in_head_chunk = count;
				}
				--hh.num_remaining_in_head_chunk;
				return (char8*)(hh.head) + sizeof(stbtt__hheap_chunk) + size * hh.num_remaining_in_head_chunk;
			}
		}

		static void stbtt__hheap_free(stbtt__hheap* hh, void* p)
		{
			*(void**)p = hh.first_free;
			hh.first_free = p;
		}

		static void stbtt__hheap_cleanup(stbtt__hheap* hh, void* userdata)
		{
			stbtt__hheap_chunk* c = hh.head;
			while (c != null)
			{
				stbtt__hheap_chunk* n = c.next;
				STBTT_free!(c, userdata);
				c = n;
			}
		}

		struct stbtt__edge
		{
			public float x0, y0, x1, y1;
			public int32 invert;
		}

		struct stbtt__active_edge
		{
			public stbtt__active_edge* next;
			#if STBTT_RASTERIZER_VERSION_1
			public int32 x,dx;
			public float ey;
			public int32 direction;
			#elif STBTT_RASTERIZER_VERSION_2
			public float fx, fdx, fdy;
			public float direction;
			public float sy;
			public float ey;
			#else
			#error "Unrecognized value of STBTT_RASTERIZER_VERSION"
			#endif
		}

#if STBTT_RASTERIZER_VERSION_1
		 const int STBTT_FIXSHIFT = 10;
		 const int STBTT_FIX = (1 << STBTT_FIXSHIFT);
		 const int STBTT_FIXMASK = (STBTT_FIX-1);

		 static stbtt__active_edge *stbtt__new_active(stbtt__hheap *hh, stbtt__edge *e, int32 off_x, float start_point, void *userdata)
		 {
			stbtt__active_edge *z = (stbtt__active_edge *) stbtt__hheap_alloc(hh, sizeof(stbtt__active_edge), userdata);
			float dxdy = (e.x1 - e.x0) / (e.y1 - e.y0);
			STBTT_assert!(z != null);
			if (z == null) return z;

			// round dx down to avoid overshooting
			if (dxdy < 0)
			   z.dx = -STBTT_ifloor!(STBTT_FIX * -dxdy);
			else
			   z.dx = STBTT_ifloor!(STBTT_FIX * dxdy);

			z.x = STBTT_ifloor!(STBTT_FIX * e.x0 + z.dx * (start_point - e.y0)); // use z.dx so when we offset later it's by the same amount
			z.x -= off_x * STBTT_FIX;

			z.ey = e.y1;
			z.next = null;
			z.direction = e.invert != 0 ? 1 : -1;
			return z;
		 }
#elif STBTT_RASTERIZER_VERSION_2
		static stbtt__active_edge* stbtt__new_active(stbtt__hheap* hh, stbtt__edge* e, int32 off_x, float start_point, void* userdata)
		{
			stbtt__active_edge* z = (stbtt__active_edge*)stbtt__hheap_alloc(hh, sizeof(stbtt__active_edge), userdata);
			float dxdy = (e.x1 - e.x0) / (e.y1 - e.y0);
			STBTT_assert!(z != null);
			//STBTT_assert!(e.y0 <= start_point);
			if (z == null) return z;
			z.fdx = dxdy;
			z.fdy = dxdy != 0.0f ? (1.0f / dxdy) : 0.0f;
			z.fx = e.x0 + dxdy * (start_point - e.y0);
			z.fx -= off_x;
			z.direction = e.invert != 0 ? 1.0f : -1.0f;
			z.sy = e.y0;
			z.ey = e.y1;
			z.next = null;
			return z;
		}
#else
		#error "Unrecognized value of STBTT_RASTERIZER_VERSION"
#endif

#if STBTT_RASTERIZER_VERSION_1
		 // note: this routine clips fills that extend off the edges... ideally this
		 // wouldn't happen, but it could happen if the truetype glyph bounding boxes
		 // are wrong, or if the user supplies a too-small bitmap
		 static void stbtt__fill_active_edges(uint8 *scanline, int32 len, stbtt__active_edge *e, int32 max_weight)
		 {
			 var e;

			// non-zero winding fill
			int32 x0=0, w=0;

			while (e != null) {
			   if (w == 0) {
				  // if we're currently at zero, we need to record the edge start point
				  x0 = e.x; w += e.direction;
			   } else {
				  int32 x1 = e.x; w += e.direction;
				  // if we went to zero, we need to draw
				  if (w == 0) {
					 int32 i = x0 >> STBTT_FIXSHIFT;
					 int32 j = x1 >> STBTT_FIXSHIFT;

					 if (i < len && j >= 0) {
						if (i == j) {
						   // x0,x1 are the same pixel, so compute combined coverage
						   scanline[i] = (.)((int32)scanline[i] + (stbtt_uint8) ((x1 - x0) * max_weight >> STBTT_FIXSHIFT));
						} else {
						   if (i >= 0) // add antialiasing for x0
							  scanline[i] = (.)((int32)scanline[i] + (stbtt_uint8) (((STBTT_FIX - (x0 & STBTT_FIXMASK)) * max_weight) >> STBTT_FIXSHIFT));
						   else
							  i = -1; // clip

						   if (j < len) // add antialiasing for x1
							  scanline[j] = (.)((int32)scanline[j] + (stbtt_uint8) (((x1 & STBTT_FIXMASK) * max_weight) >> STBTT_FIXSHIFT));
						   else
							  j = len; // clip

							++i;
						   for (; i < j; ++i) // fill pixels between x0 and x1
							  scanline[i] = (.)((int32)scanline[i] + (stbtt_uint8) max_weight);
						}
					 }
				  }
			   }

			   e = e.next;
			}
		 }

		 static void stbtt__rasterize_sorted_edges(stbtt__bitmap *result, stbtt__edge *e, int32 n, int32 vsubsample, int32 off_x, int32 off_y, void *userdata)
		 {
			 var e;

			stbtt__hheap hh = default;
			stbtt__active_edge *active = null;
			int32 y,j=0;
			int32 max_weight = (255 / vsubsample);  // weight per vertical scanline
			int32 s; // vertical subsample index
			uint8[512] scanline_data = default; uint8 *scanline;

			if (result.w > 512)
			   scanline = (uint8 *) STBTT_malloc!(result.w, userdata);
			else
			   scanline = &scanline_data[0];

			y = off_y * vsubsample;
			e[n].y0 = (off_y + result.h) * (float) vsubsample + 1;

			while (j < result.h) {
			   STBTT_memset!(scanline, 0, result.w);
			   for (s=0; s < vsubsample; ++s) {
				  // find center of pixel for this scanline
				  float scan_y = y + 0.5f;
				  stbtt__active_edge **step = &active;

				  // update all active edges;
				  // remove all active edges that terminate before the center of this scanline
				  while (*step != null) {
					 stbtt__active_edge * z = *step;
					 if (z.ey <= scan_y) {
						*step = z.next; // delete from list
						STBTT_assert!(z.direction != 0);
						z.direction = 0;
						stbtt__hheap_free(&hh, z);
					 } else {
						z.x += z.dx; // advance to position for current scanline
						step = &((*step).next); // advance through list
					 }
				  }

				  // resort the list if needed
				  for(;;) {
					 int32 changed=0;
					 step = &active;
					 while (*step != null && (*step).next != null) {
						if ((*step).x > (*step).next.x) {
						   stbtt__active_edge *t = *step;
						   stbtt__active_edge *q = t.next;

						   t.next = q.next;
						   q.next = t;
						   *step = q;
						   changed = 1;
						}
						step = &(*step).next;
					 }
					 if (changed == 0) break;
				  }

				  // insert all edges that start before the center of this scanline -- omit ones that also end on this scanline
				  while (e.y0 <= scan_y) {
					 if (e.y1 > scan_y) {
						stbtt__active_edge *z = stbtt__new_active(&hh, e, off_x, scan_y, userdata);
						if (z != null) {
						   // find insertion point
						   if (active == null)
							  active = z;
						   else if (z.x < active.x) {
							  // insert at front
							  z.next = active;
							  active = z;
						   } else {
							  // find thing to insert AFTER
							  stbtt__active_edge *p = active;
							  while (p.next != null && p.next.x < z.x)
								 p = p.next;
							  // at this point, p.next.x is NOT < z.x
							  z.next = p.next;
							  p.next = z;
						   }
						}
					 }
					 ++e;
				  }

				  // now process all active edges in XOR fashion
				  if (active != null)
					 stbtt__fill_active_edges(scanline, result.w, active, max_weight);

				  ++y;
			   }
			   STBTT_memcpy!(result.pixels + j * result.stride, scanline, result.w);
			   ++j;
			}

			stbtt__hheap_cleanup(&hh, userdata);

			if (scanline != &scanline_data[0])
			   STBTT_free!(scanline, userdata);
		 }

#elif STBTT_RASTERIZER_VERSION_2

		 // the edge passed in here does not cross the vertical line at x or the vertical line at x+1
		 // (i.e. it has already been clipped to those)
		static void stbtt__handle_clipped_edge(float* scanline, int32 x, stbtt__active_edge* e, float x0, float y0, float x1, float y1)
		{
			var x0, y0, x1, y1;

			if (y0 == y1) return;
			STBTT_assert!(y0 < y1);
			STBTT_assert!(e.sy <= e.ey);
			if (y0 > e.ey) return;
			if (y1 < e.sy) return;
			if (y0 < e.sy)
			{
				x0 += (x1 - x0) * (e.sy - y0) / (y1 - y0);
				y0 = e.sy;
			}
			if (y1 > e.ey)
			{
				x1 += (x1 - x0) * (e.ey - y1) / (y1 - y0);
				y1 = e.ey;
			}

			if (x0 == x)
				STBTT_assert!(x1 <= x + 1);
			else if (x0 == x + 1)
				STBTT_assert!(x1 >= x);
			else if (x0 <= x)
				STBTT_assert!(x1 <= x);
			else if (x0 >= x + 1)
				STBTT_assert!(x1 >= x + 1);
			else
				STBTT_assert!(x1 >= x && x1 <= x + 1);

			if (x0 <= x && x1 <= x)
				scanline[x] += e.direction * (y1 - y0);
			else if (x0 >= x + 1 && x1 >= x + 1)
				NOP!();
			else
			{
				STBTT_assert!(x0 >= x && x0 <= x + 1 && x1 >= x && x1 <= x + 1);
				scanline[x] += e.direction * (y1 - y0) * (1 - ((x0 - x) + (x1 - x)) / 2);// coverage = 1 - average x position
			}
		}

		static float stbtt__sized_trapezoid_area(float height, float top_width, float bottom_width)
		{
			STBTT_assert!(top_width >= 0);
			STBTT_assert!(bottom_width >= 0);
			return (top_width + bottom_width) / 2.0f * height;
		}

		static float stbtt__position_trapezoid_area(float height, float tx0, float tx1, float bx0, float bx1)
		{
			return stbtt__sized_trapezoid_area(height, tx1 - tx0, bx1 - bx0);
		}

		static float stbtt__sized_triangle_area(float height, float width)
		{
			return height * width / 2;
		}

		static void stbtt__fill_active_edges_new(float* scanline, float* scanline_fill, int32 len, stbtt__active_edge* e, float y_top)
		{
			float y_bottom = y_top + 1;
			var e;
			while (e != null)
			{
			   // brute force every pixel

			   // compute intersection points with top & bottom
				STBTT_assert!(e.ey >= y_top);

				if (e.fdx == 0)
				{
					float x0 = e.fx;
					if (x0 < len)
					{
						if (x0 >= 0)
						{
							stbtt__handle_clipped_edge(scanline, (int32)x0, e, x0, y_top, x0, y_bottom);
							stbtt__handle_clipped_edge(scanline_fill - 1, (int32)x0 + 1, e, x0, y_top, x0, y_bottom);
						} else {
							stbtt__handle_clipped_edge(scanline_fill - 1, 0, e, x0, y_top, x0, y_bottom);
						}
					}
				} else {
					float x0 = e.fx;
					float dx = e.fdx;
					float xb = x0 + dx;
					float x_top, x_bottom;
					float sy0, sy1;
					float dy = e.fdy;
					STBTT_assert!(e.sy <= y_bottom && e.ey >= y_top);

					// compute endpoints of line segment clipped to this scanline (if the
					// line segment starts on this scanline. x0 is the intersection of the
					// line with y_top, but that may be off the line segment.
					if (e.sy > y_top)
					{
						x_top = x0 + dx * (e.sy - y_top);
						sy0 = e.sy;
					} else {
						x_top = x0;
						sy0 = y_top;
					}
					if (e.ey < y_bottom)
					{
						x_bottom = x0 + dx * (e.ey - y_top);
						sy1 = e.ey;
					} else {
						x_bottom = xb;
						sy1 = y_bottom;
					}

					if (x_top >= 0 && x_bottom >= 0 && x_top < len && x_bottom < len)
					{
					   // from here on, we don't have to range check x values

						if ((int32)x_top == (int32)x_bottom)
						{
							float height;
							// simple case, only spans one pixel
							int32 x = (int32)x_top;
							height = (sy1 - sy0) * e.direction;
							STBTT_assert!(x >= 0 && x < len);
							scanline[x] += stbtt__position_trapezoid_area(height, x_top, x + 1.0f, x_bottom, x + 1.0f);
							scanline_fill[x] += height;// everything right of this pixel is filled
						} else {
							int32 x, x1, x2;
							float y_crossing, y_final, step, sign, area;
							// covers 2+ pixels
							if (x_top > x_bottom)
							{
							   // flip scanline vertically; signed area is the same
								float t;
								sy0 = y_bottom - (sy0 - y_top);
								sy1 = y_bottom - (sy1 - y_top);
								t = sy0; sy0 = sy1; sy1 = t;
								t = x_bottom; x_bottom = x_top; x_top = t;
								dx = -dx;
								dy = -dy;
								t = x0; x0 = xb; xb = t;
							}
							STBTT_assert!(dy >= 0);
							STBTT_assert!(dx >= 0);

							x1 = (int32)x_top;
							x2 = (int32)x_bottom;
							// compute intersection with y axis at x1+1
							y_crossing = y_top + dy * (x1 + 1 - x0);

							// compute intersection with y axis at x2
							y_final = y_top + dy * (x2 - x0);

							//           x1    x_top                            x2    x_bottom
							//     y_top  +------|-----+------------+------------+--------|---+------------+
							//            |            |            |            |            |            |
							//            |            |            |            |            |            |
							//       sy0  |      Txxxxx|............|............|............|............|
							// y_crossing |            *xxxxx.......|............|............|............|
							//            |            |     xxxxx..|............|............|............|
							//            |            |     /-   xx*xxxx........|............|............|
							//            |            | dy <       |    xxxxxx..|............|............|
							//   y_final  |            |     \-     |          xx*xxx.........|............|
							//       sy1  |            |            |            |   xxxxxB...|............|
							//            |            |            |            |            |            |
							//            |            |            |            |            |            |
							//  y_bottom  +------------+------------+------------+------------+------------+
							//
							// goal is to measure the area covered by '.' in each pixel

							// if x2 is right at the right edge of x1, y_crossing can blow up, github #1057
							// @TODO: maybe test against sy1 rather than y_bottom?
							if (y_crossing > y_bottom)
								y_crossing = y_bottom;

							sign = e.direction;

							// area of the rectangle covered from sy0..y_crossing
							area = sign * (y_crossing - sy0);

							// area of the triangle (x_top,sy0), (x1+1,sy0), (x1+1,y_crossing)
							scanline[x1] += stbtt__sized_triangle_area(area, x1 + 1 - x_top);

							// check if final y_crossing is blown up; no test case for this
							if (y_final > y_bottom)
							{
								y_final = y_bottom;
								dy = (y_final - y_crossing) / (x2 - (x1 + 1));// if denom=0, y_final = y_crossing, so y_final <= y_bottom
							}

							// in second pixel, area covered by line segment found in first pixel
							// is always a rectangle 1 wide * the height of that line segment; this
							// is exactly what the variable 'area' stores. it also gets a contribution
							// from the line segment within it. the THIRD pixel will get the first
							// pixel's rectangle contribution, the second pixel's rectangle contribution,
							// and its own contribution. the 'own contribution' is the same in every pixel except
							// the leftmost and rightmost, a trapezoid that slides down in each pixel.
							// the second pixel's contribution to the third pixel will be the
							// rectangle 1 wide times the height change in the second pixel, which is dy.

							step = sign * dy * 1;// dy is dy/dx, change in y for every 1 change in x,
							// which multiplied by 1-pixel-width is how much pixel area changes for each step in x
							// so the area advances by 'step' every time

							for (x = x1 + 1; x < x2; ++x)
							{
								scanline[x] += area + step / 2;// area of trapezoid is 1*step/2
								area += step;
							}
							STBTT_assert!(STBTT_fabs!(area) <= 1.01f);// accumulated error from area += step unless we
							// round step down
							STBTT_assert!(sy1 > y_final - 0.01f);

							// area covered in the last pixel is the rectangle from all the pixels to the left,
							// plus the trapezoid filled by the line segment in this pixel all the way to the right edge
							scanline[x2] += area + sign * stbtt__position_trapezoid_area(sy1 - y_final, (float)x2, x2 + 1.0f, x_bottom, x2 + 1.0f);

							// the rest of the line is filled based on the total height of the line segment in this
							// pixel
							scanline_fill[x2] += sign * (sy1 - sy0);
						}
					} else {
					   // if edge goes outside of box we're drawing, we require
					   // clipping logic. since this does not match the intended use
					   // of this library, we use a different, very slow brute
					   // force implementation
					   // note though that this does happen some of the time because
					   // x_top and x_bottom can be extrapolated at the top & bottom of
					   // the shape and actually lie outside the bounding box
						int32 x;
						for (x = 0; x < len; ++x)
						{
						  // cases:
						  //
						  // there can be up to two intersections with the pixel. any intersection
						  // with left or right edges can be handled by splitting into two (or three)
						  // regions. intersections with top & bottom do not necessitate case-wise logic.
						  //
						  // the old way of doing this found the intersections with the left & right edges,
						  // then used some simple logic to produce up to three segments in sorted order
						  // from top-to-bottom. however, this had a problem: if an x edge was epsilon
						  // across the x border, then the corresponding y position might not be distinct
						  // from the other y segment, and it might ignored as an empty segment. to avoid
						  // that, we need to explicitly produce segments based on x positions.

						  // rename variables to clearly-defined pairs
							float y0 = y_top;
							float x1 = (float)(x);
							float x2 = (float)(x + 1);
							float x3 = xb;
							float y3 = y_bottom;

						  // x = e.x + e.dx * (y-y_top)
						  // (y-y_top) = (x - e.x) / e.dx
						  // y = (x - e.x) / e.dx + y_top
							float y1 = (x - x0) / dx + y_top;
							float y2 = (x + 1 - x0) / dx + y_top;

							if (x0 < x1 && x3 > x2)
							{// three segments descending down-right
								stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x1, y1);
								stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x2, y2);
								stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x3, y3);
							} else if (x3 < x1 && x0 > x2) {// three segments descending down-left
								stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x2, y2);
								stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x1, y1);
								stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x3, y3);
							} else if (x0 < x1 && x3 > x1) {// two segments across x, down-right
								stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x1, y1);
								stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x3, y3);
							} else if (x3 < x1 && x0 > x1) {// two segments across x, down-left
								stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x1, y1);
								stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x3, y3);
							} else if (x0 < x2 && x3 > x2) {// two segments across x+1, down-right
								stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x2, y2);
								stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x3, y3);
							} else if (x3 < x2 && x0 > x2) {// two segments across x+1, down-left
								stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x2, y2);
								stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x3, y3);
							} else {// one segment
								stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x3, y3);
							}
						}
					}
				}
				e = e.next;
			}
		}

		 // directly AA rasterize edges w/o supersampling
		static void stbtt__rasterize_sorted_edges(stbtt__bitmap* result, stbtt__edge* e, int32 n, int32 vsubsample, int32 off_x, int32 off_y, void* userdata)
		{
			var e;
			stbtt__hheap hh = default;
			stbtt__active_edge* active = null;
			int32 y, j = 0, i;
			float[129] scanline_data = ?; float* scanline, scanline2;

		   //STBTT__NOTUSED(vsubsample);

			if (result.w > 64)
				scanline = (float*)STBTT_malloc!((result.w * 2 + 1) * sizeof(float), userdata);
			else
				scanline = &scanline_data[0];

			scanline2 = scanline + result.w;

			y = off_y;
			e[n].y0 = (float)(off_y + result.h) + 1;

			while (j < result.h)
			{
			  // find center of pixel for this scanline
				float scan_y_top = y + 0.0f;
				float scan_y_bottom = y + 1.0f;
				stbtt__active_edge** step = &active;

				STBTT_memset!(scanline, 0, result.w * sizeof(float));
				STBTT_memset!(scanline2, 0, (result.w + 1) * sizeof(float));

			  // update all active edges;
			  // remove all active edges that terminate before the top of this scanline
				while (*step != null)
				{
					stbtt__active_edge* z = *step;
					if (z.ey <= scan_y_top)
					{
						*step = z.next;// delete from list
						STBTT_assert!(z.direction != 0);
						z.direction = 0;
						stbtt__hheap_free(&hh, z);
					} else {
						step = &((*step).next);// advance through list
					}
				}

			  // insert all edges that start before the bottom of this scanline
				while (e.y0 <= scan_y_bottom)
				{
					if (e.y0 != e.y1)
					{
						stbtt__active_edge* z = stbtt__new_active(&hh, e, off_x, scan_y_top, userdata);
						if (z != null)
						{
							if (j == 0 && off_y != 0)
							{
								if (z.ey < scan_y_top)
								{
									// this can happen due to subpixel positioning and some kind of fp rounding error i
									// think
									z.ey = scan_y_top;
								}
							}
							STBTT_assert!(z.ey >= scan_y_top);// if we get really unlucky a tiny bit of an edge can be out of bounds
							// insert at front
							z.next = active;
							active = z;
						}
					}
					++e;
				}

			  // now process all active edges
				if (active != null)
					stbtt__fill_active_edges_new(scanline, scanline2 + 1, result.w, active, scan_y_top);
				{
					float sum = 0;
					for (i = 0; i < result.w; ++i)
					{
						float k;
						int32 m;
						sum += scanline2[i];
						k = scanline[i] + sum;
						k = (float)STBTT_fabs!(k) * 255 + 0.5f;
						m = (int32)k;
						if (m > 255) m = 255;
						result.pixels[j * result.stride + i] = (uint8)m;
					}
				}
			  // advance all the edges
				step = &active;
				while (*step != null)
				{
					stbtt__active_edge* z = *step;
					z.fx += z.fdx;// advance to position for current scanline
					step = &((*step).next);// advance through list
				}

				++y;
				++j;
			}

			stbtt__hheap_cleanup(&hh, userdata);

			if (scanline != &scanline_data[0])
				STBTT_free!(scanline, userdata);
		}
#else
		#error "Unrecognized value of STBTT_RASTERIZER_VERSION"
#endif

		static void stbtt__sort_edges_ins_sort(stbtt__edge* p, int32 n)
		{
			int32 i, j;
			for (i = 1; i < n; ++i)
			{
				stbtt__edge t = p[i]; stbtt__edge* a = &t;
				j = i;
				while (j > 0)
				{
					stbtt__edge* b = &p[j - 1];
					bool c = (a.y0 < b.y0);
					if (!c) break;
					p[j] = p[j - 1];
					--j;
				}
				if (i != j)
					p[j] = t;
			}
		}

		static void stbtt__sort_edges_quicksort(stbtt__edge* p, int32 n)
		{
			var p, n;

		   /* threshold for transitioning to insertion sort */
			while (n > 12)
			{
				stbtt__edge t;
				bool c01, c12, c; int32 m, i, j;

				/* compute median of three */
				m = n >> 1;
				c01 = (&p[0].y0 < &p[m].y0);
				c12 = (&p[m].y0 < &p[n - 1].y0);
				/* if 0 >= mid >= end, or 0 < mid < end, then use mid */
				if (c01 != c12)
				{
				   /* otherwise, we'll need to swap something else to middle */
					int32 z;
					c = (&p[0].y0 < &p[n - 1].y0);
				   /* 0>mid && mid<n:  0>n => n; 0<n => 0 */
				   /* 0<mid && mid>n:  0>n => 0; 0<n => n */
					z = (c == c12) ? 0 : n - 1;
					t = p[z];
					p[z] = p[m];
					p[m] = t;
				}
				/* now p[m] is the median-of-three */
				/* swap it to the beginning so it won't move around */
				t = p[0];
				p[0] = p[m];
				p[m] = t;

				/* partition loop */
				i = 1;
				j = n - 1;
				for (;;)
				{
				   /* handling of equality is crucial here */
				   /* for sentinels & efficiency with duplicates */
					for (;; ++i)
					{
						if ((&p[i].y0 >= &p[0].y0)) break;
					}
					for (;; --j)
					{
						if ((&p[0].y0 >= &p[j].y0)) break;
					}
				   /* make sure we haven't crossed */
					if (i >= j) break;
					t = p[i];
					p[i] = p[j];
					p[j] = t;

					++i;
					--j;
				}
				/* recurse on smaller side, iterate on larger */
				if (j < (n - i))
				{
					stbtt__sort_edges_quicksort(p, j);
					p = p + i;
					n = n - i;
				} else {
					stbtt__sort_edges_quicksort(p + i, n - i);
					n = j;
				}
			}
		}

		static void stbtt__sort_edges(stbtt__edge* p, int32 n)
		{
			stbtt__sort_edges_quicksort(p, n);
			stbtt__sort_edges_ins_sort(p, n);
		}

		struct stbtt__point
		{
			public float x, y;
		}

		static void stbtt__rasterize(stbtt__bitmap* result, stbtt__point* pts, int32* wcount, int32 windings, float scale_x, float scale_y, float shift_x, float shift_y, int32 off_x, int32 off_y, bool invert, void* userdata)
		{
			float y_scale_inv = invert ? -scale_y : scale_y;
			stbtt__edge* e;
			int32 n, i, j, k, m;
#if STBTT_RASTERIZER_VERSION_1
			int32 vsubsample = result.h < 8 ? 15 : 5;
#elif STBTT_RASTERIZER_VERSION_2
			int32 vsubsample = 1;
#else
			#error "Unrecognized value of STBTT_RASTERIZER_VERSION"
#endif
			// vsubsample should divide 255 evenly; otherwise we won't reach full opacity

			// now we have to blow out the windings into explicit edge lists
			n = 0;
			for (i = 0; i < windings; ++i)
				n += wcount[i];

			e = (stbtt__edge*)STBTT_malloc!(sizeof(stbtt__edge) * (n + 1), userdata);// add an extra one as a sentinel
			if (e == null) return;
			n = 0;

			m = 0;
			for (i = 0; i < windings; ++i)
			{
				stbtt__point* p = pts + m;
				m += wcount[i];
				j = wcount[i] - 1;
				for (k = 0; k < wcount[i]; j = k++)
				{
					int32 a = k, b = j;
					// skip the edge if horizontal
					if (p[j].y == p[k].y)
						continue;
					// add edge from j to k to the list
					e[n].invert = 0;
					if (invert ? p[j].y > p[k].y : p[j].y < p[k].y)
					{
						e[n].invert = 1;
						a = j; b = k;
					}
					e[n].x0 = p[a].x * scale_x + shift_x;
					e[n].y0 = (p[a].y * y_scale_inv + shift_y) * vsubsample;
					e[n].x1 = p[b].x * scale_x + shift_x;
					e[n].y1 = (p[b].y * y_scale_inv + shift_y) * vsubsample;
					++n;
				}
			}

			// now sort the edges by their highest point (should snap to integer, and then by x)
			//STBTT_sort(e, n, sizeof(e[0]), stbtt__edge_compare);
			stbtt__sort_edges(e, n);

			// now, traverse the scanlines and find the intersections on each scanline, use xor winding rule
			stbtt__rasterize_sorted_edges(result, e, n, vsubsample, off_x, off_y, userdata);

			STBTT_free!(e, userdata);
		}

		static void stbtt__add_point(stbtt__point* points, int32 n, float x, float y)
		{
			if (points == null) return;// during first pass, it's unallocated
			points[n].x = x;
			points[n].y = y;
		}

		 // tessellate until threshold p is happy... @TODO warped to compensate for non-linear stretching
		static int32 stbtt__tesselate_curve(stbtt__point* points, int32* num_points, float x0, float y0, float x1, float y1, float x2, float y2, float objspace_flatness_squared, int32 n)
		{
		   // midpoint
			float mx = (x0 + 2 * x1 + x2) / 4;
			float my = (y0 + 2 * y1 + y2) / 4;
		   // versus directly drawn line
			float dx = (x0 + x2) / 2 - mx;
			float dy = (y0 + y2) / 2 - my;
			if (n > 16)// 65536 segments on one curve better be enough!
				return 1;
			if (dx * dx + dy * dy > objspace_flatness_squared)
			{// half-pixel error allowed... need to be smaller if AA
				stbtt__tesselate_curve(points, num_points, x0, y0, (x0 + x1) / 2.0f, (y0 + y1) / 2.0f, mx, my, objspace_flatness_squared, n + 1);
				stbtt__tesselate_curve(points, num_points, mx, my, (x1 + x2) / 2.0f, (y1 + y2) / 2.0f, x2, y2, objspace_flatness_squared, n + 1);
			} else {
				stbtt__add_point(points, *num_points, x2, y2);
				*num_points = *num_points + 1;
			}
			return 1;
		}

		static void stbtt__tesselate_cubic(stbtt__point* points, int32* num_points, float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3, float objspace_flatness_squared, int32 n)
		{
		   // @TODO this "flatness" calculation is just made-up nonsense that seems to work well enough
			float dx0 = x1 - x0;
			float dy0 = y1 - y0;
			float dx1 = x2 - x1;
			float dy1 = y2 - y1;
			float dx2 = x3 - x2;
			float dy2 = y3 - y2;
			float dx = x3 - x0;
			float dy = y3 - y0;
			float longlen = (float)(STBTT_sqrt!(dx0 * dx0 + dy0 * dy0) + STBTT_sqrt!(dx1 * dx1 + dy1 * dy1) + STBTT_sqrt!(dx2 * dx2 + dy2 * dy2));
			float shortlen = (float)STBTT_sqrt!(dx * dx + dy * dy);
			float flatness_squared = longlen * longlen - shortlen * shortlen;

			if (n > 16)// 65536 segments on one curve better be enough!
				return;

			if (flatness_squared > objspace_flatness_squared)
			{
				float x01 = (x0 + x1) / 2;
				float y01 = (y0 + y1) / 2;
				float x12 = (x1 + x2) / 2;
				float y12 = (y1 + y2) / 2;
				float x23 = (x2 + x3) / 2;
				float y23 = (y2 + y3) / 2;

				float xa = (x01 + x12) / 2;
				float ya = (y01 + y12) / 2;
				float xb = (x12 + x23) / 2;
				float yb = (y12 + y23) / 2;

				float mx = (xa + xb) / 2;
				float my = (ya + yb) / 2;

				stbtt__tesselate_cubic(points, num_points, x0, y0, x01, y01, xa, ya, mx, my, objspace_flatness_squared, n + 1);
				stbtt__tesselate_cubic(points, num_points, mx, my, xb, yb, x23, y23, x3, y3, objspace_flatness_squared, n + 1);
			} else {
				stbtt__add_point(points, *num_points, x3, y3);
				*num_points = *num_points + 1;
			}
		}

		 // returns number of contours
		static stbtt__point* stbtt_FlattenCurves(stbtt_vertex* vertices, int32 num_verts, float objspace_flatness, int32** contour_lengths, int32* num_contours, void* userdata)
		{
			stbtt__point* points = null;
			int32 num_points = 0;

			float objspace_flatness_squared = objspace_flatness * objspace_flatness;
			int32 i, n = 0, start = 0, pass;

			// count how many "moves" there are to get the contour count
			for (i = 0; i < num_verts; ++i)
				if (vertices[i].type == STBTT_vmove)
					++n;

			*num_contours = n;
			if (n == 0) return null;

			*contour_lengths = (int32*)STBTT_malloc!(sizeof(int32) * n, userdata);

			if (*contour_lengths == null)
			{
				*num_contours = 0;
				return null;
			}

			// make two passes through the points so we don't need to realloc
			for (pass = 0; pass < 2; ++pass)
			{
				float x = 0, y = 0;
				if (pass == 1)
				{
					points = (stbtt__point*)STBTT_malloc!(num_points * sizeof(stbtt__point), userdata);
					if (points == null)
					{
						// goto error;
						STBTT_free!(points, userdata);
						STBTT_free!(*contour_lengths, userdata);
						*contour_lengths = null;
						*num_contours = 0;
						return null;
					}
				}
				num_points = 0;
				n = -1;
				for (i = 0; i < num_verts; ++i)
				{
					switch (vertices[i].type) {
					case STBTT_vmove:
						  // start the next contour
						if (n >= 0)
							(*contour_lengths)[n] = num_points - start;
						++n;
						start = num_points;

						x = vertices[i].x; y = vertices[i].y;
						stbtt__add_point(points, num_points++, x, y);
						break;
					case STBTT_vline:
						x = vertices[i].x; y = vertices[i].y;
						stbtt__add_point(points, num_points++, x, y);
						break;
					case STBTT_vcurve:
						stbtt__tesselate_curve(points, &num_points, x, y,
							vertices[i].cx, vertices[i].cy,
							vertices[i].x, vertices[i].y,
							objspace_flatness_squared, 0);
						x = vertices[i].x; y = vertices[i].y;
						break;
					case STBTT_vcubic:
						stbtt__tesselate_cubic(points, &num_points, x, y,
							vertices[i].cx, vertices[i].cy,
							vertices[i].cx1, vertices[i].cy1,
							vertices[i].x, vertices[i].y,
							objspace_flatness_squared, 0);
						x = vertices[i].x; y = vertices[i].y;
						break;
					}
				}
				(*contour_lengths)[n] = num_points - start;
			}

			return points;
		}

		public static void stbtt_Rasterize(stbtt__bitmap* result, float flatness_in_pixels, stbtt_vertex* vertices, int32 num_verts, float scale_x, float scale_y, float shift_x, float shift_y, int32 x_off, int32 y_off, bool invert, void* userdata)
		{
			float scale = scale_x > scale_y ? scale_y : scale_x;
			int32 winding_count = 0;
			int32* winding_lengths = null;
			stbtt__point* windings = stbtt_FlattenCurves(vertices, num_verts, flatness_in_pixels / scale, &winding_lengths, &winding_count, userdata);
			if (windings != null)
			{
				stbtt__rasterize(result, windings, winding_lengths, winding_count, scale_x, scale_y, shift_x, shift_y, x_off, y_off, invert, userdata);
				STBTT_free!(winding_lengths, userdata);
				STBTT_free!(windings, userdata);
			}
		}

		public static void stbtt_FreeBitmap(uint8* bitmap, void* userdata)
		{
			STBTT_free!(bitmap, userdata);
		}

		public static uint8* stbtt_GetGlyphBitmapSubpixel(stbtt_fontinfo* info, float scale_x, float scale_y, float shift_x, float shift_y, int32 glyph, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			var scale_x, scale_y;
			int32 ix0 = ?, iy0 = ?, ix1 = ?, iy1 = ?;
			stbtt__bitmap gbm;
			stbtt_vertex* vertices = null;
			int32 num_verts = stbtt_GetGlyphShape(info, glyph, &vertices);

			if (scale_x == 0) scale_x = scale_y;
			if (scale_y == 0)
			{
				if (scale_x == 0)
				{
					STBTT_free!(vertices, info.userdata);
					return null;
				}
				scale_y = scale_x;
			}

			stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y, &ix0, &iy0, &ix1, &iy1);

		   // now we get the size
			gbm.w = (ix1 - ix0);
			gbm.h = (iy1 - iy0);
			gbm.pixels = null;// in case we error

			if (width != null) *width = gbm.w;
			if (height != null) *height = gbm.h;
			if (xoff != null) *xoff = ix0;
			if (yoff != null) *yoff = iy0;

			if (gbm.w != 0 && gbm.h != 0)
			{
				gbm.pixels = (uint8*)STBTT_malloc!(gbm.w * gbm.h, info.userdata);
				if (gbm.pixels != null)
				{
					gbm.stride = gbm.w;

					stbtt_Rasterize(&gbm, 0.35f, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0, iy0, true, info.userdata);
				}
			}
			STBTT_free!(vertices, info.userdata);
			return gbm.pixels;
		}

		public static uint8* stbtt_GetGlyphBitmap(stbtt_fontinfo* info, float scale_x, float scale_y, int32 glyph, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y, 0.0f, 0.0f, glyph, width, height, xoff, yoff);
		}

		public static void stbtt_MakeGlyphBitmapSubpixel(stbtt_fontinfo* info, uint8* output, int32 out_w, int32 out_h, int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 glyph)
		{
			int32 ix0 = ?, iy0 = ?;
			stbtt_vertex* vertices = null;
			int32 num_verts = stbtt_GetGlyphShape(info, glyph, &vertices);
			stbtt__bitmap gbm;

			stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y, &ix0, &iy0, null, null);
			gbm.pixels = output;
			gbm.w = out_w;
			gbm.h = out_h;
			gbm.stride = out_stride;

			if (gbm.w != 0 && gbm.h != 0)
				stbtt_Rasterize(&gbm, 0.35f, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0, iy0, true, info.userdata);

			STBTT_free!(vertices, info.userdata);
		}

		public static void stbtt_MakeGlyphBitmap(stbtt_fontinfo* info, uint8* output, int32 out_w, int32 out_h, int32 out_stride, float scale_x, float scale_y, int32 glyph)
		{
			stbtt_MakeGlyphBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, 0.0f, 0.0f, glyph);
		}

		public static uint8* stbtt_GetCodepointBitmapSubpixel(stbtt_fontinfo* info, float scale_x, float scale_y, float shift_x, float shift_y, int32 codepoint, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y, shift_x, shift_y, stbtt_FindGlyphIndex(info, codepoint), width, height, xoff, yoff);
		}

		public static void stbtt_MakeCodepointBitmapSubpixelPrefilter(stbtt_fontinfo* info, uint8* output, int32 out_w, int32 out_h, int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 oversample_x, int32 oversample_y, float* sub_x, float* sub_y, int32 codepoint)
		{
			stbtt_MakeGlyphBitmapSubpixelPrefilter(info, output, out_w, out_h, out_stride, scale_x, scale_y, shift_x, shift_y, oversample_x, oversample_y, sub_x, sub_y, stbtt_FindGlyphIndex(info, codepoint));
		}

		public static void stbtt_MakeCodepointBitmapSubpixel(stbtt_fontinfo* info, uint8* output, int32 out_w, int32 out_h, int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 codepoint)
		{
			stbtt_MakeGlyphBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, shift_x, shift_y, stbtt_FindGlyphIndex(info, codepoint));
		}

		public static uint8* stbtt_GetCodepointBitmap(stbtt_fontinfo* info, float scale_x, float scale_y, int32 codepoint, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetCodepointBitmapSubpixel(info, scale_x, scale_y, 0.0f, 0.0f, codepoint, width, height, xoff, yoff);
		}

		public static void stbtt_MakeCodepointBitmap(stbtt_fontinfo* info, uint8* output, int32 out_w, int32 out_h, int32 out_stride, float scale_x, float scale_y, int32 codepoint)
		{
			stbtt_MakeCodepointBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, 0.0f, 0.0f, codepoint);
		}

		 //////////////////////////////////////////////////////////////////////////////
		 //
		 // bitmap baking
		 //
		 // This is SUPER-CRAPPY packing to keep source code small

		static int32 stbtt_BakeFontBitmap_internal(uint8* data, int32 offset,// font location (use offset=0 for plain .ttf)
			float pixel_height,// height of font in pixels
			uint8* pixels, int32 pw, int32 ph,// bitmap to be filled in
			int32 first_char, int32 num_chars,// characters to bake
			stbtt_bakedchar* chardata)
		{
			float scale;
			int32 x, y, bottom_y, i;
			stbtt_fontinfo f;
			f.userdata = null;
			if (!stbtt_InitFont(&f, data, offset))
				return -1;
			STBTT_memset!(pixels, 0, pw * ph);// background of 0 around pixels
			x = y = 1;
			bottom_y = 1;

			scale = stbtt_ScaleForPixelHeight(&f, pixel_height);

			for (i = 0; i < num_chars; ++i)
			{
				int32 advance = ?, lsb, x0 = ?, y0 = ?, x1 = ?, y1 = ?, gw, gh;
				int32 g = stbtt_FindGlyphIndex(&f, first_char + i);
				stbtt_GetGlyphHMetrics(&f, g, &advance, &lsb);
				stbtt_GetGlyphBitmapBox(&f, g, scale, scale, &x0, &y0, &x1, &y1);
				gw = x1 - x0;
				gh = y1 - y0;
				if (x + gw + 1 >= pw)
					y = bottom_y; x = 1;// advance to next row
				if (y + gh + 1 >= ph)// check if it fits vertically AFTER potentially moving to next row
					return -i;
				STBTT_assert!(x + gw < pw);
				STBTT_assert!(y + gh < ph);
				stbtt_MakeGlyphBitmap(&f, pixels + x + y * pw, gw, gh, pw, scale, scale, g);
				chardata[i].x0 = (.)x;
				chardata[i].y0 = (.)y;
				chardata[i].x1 = (.)(x + gw);
				chardata[i].y1 = (.)(y + gh);
				chardata[i].xadvance = scale * advance;
				chardata[i].xoff = (float)x0;
				chardata[i].yoff = (float)y0;
				x = x + gw + 1;
				if (y + gh + 1 > bottom_y)
					bottom_y = y + gh + 1;
			}
			return bottom_y;
		}

		public static void stbtt_GetBakedQuad(stbtt_bakedchar* chardata, int32 pw, int32 ph, int32 char_index, float* xpos, float* ypos, stbtt_aligned_quad* q, bool opengl_fillrule)
		{
			float d3d_bias = opengl_fillrule ? 0 : -0.5f;
			float ipw = 1.0f / pw, iph = 1.0f / ph;
			readonly stbtt_bakedchar* b = chardata + char_index;
			int32 round_x = STBTT_ifloor!((*xpos + b.xoff) + 0.5f);
			int32 round_y = STBTT_ifloor!((*ypos + b.yoff) + 0.5f);

			q.x0 = round_x + d3d_bias;
			q.y0 = round_y + d3d_bias;
			q.x1 = round_x + b.x1 - b.x0 + d3d_bias;
			q.y1 = round_y + b.y1 - b.y0 + d3d_bias;

			q.s0 = (float)b.x0 * ipw;
			q.t0 = (float)b.y0 * iph;
			q.s1 = (float)b.x1 * ipw;
			q.t1 = (float)b.y1 * iph;

			*xpos += b.xadvance;
		}

		 //////////////////////////////////////////////////////////////////////////////
		 //
		 // rectangle packing replacement routines if you don't have stb_rect_pack.h
		 //

#if !STB_RECT_PACK_VERSION

		typealias stbrp_coord = int32;

		 ////////////////////////////////////////////////////////////////////////////////////
		 //                                                                                //
		 //                                                                                //
		 // COMPILER WARNING ?!?!?                                                         //
		 //                                                                                //
		 //                                                                                //
		 // if you get a compile warning due to these symbols being defined more than      //
		 // once, move #include "stb_rect_pack.h" before #include "stb_truetype.h"         //
		 //                                                                                //
		 ////////////////////////////////////////////////////////////////////////////////////

		struct stbrp_context
		{
			public int32 width, height;
			public int32 x, y, bottom_y;
		}

		struct stbrp_node
		{
			public uint8 x;
		}

		struct stbrp_rect
		{
			public stbrp_coord x, y;
			public int32 id, w, h;
			public bool was_packed;
		}

		static void stbrp_init_target(stbrp_context* con, int32 pw, int32 ph, stbrp_node* nodes, int32 num_nodes)
		{
			con.width = pw;
			con.height = ph;
			con.x = 0;
			con.y = 0;
			con.bottom_y = 0;
			//STBTT__NOTUSED(nodes);
			//STBTT__NOTUSED(num_nodes);
		}

		static void stbrp_pack_rects(stbrp_context* con, stbrp_rect* rects, int32 num_rects)
		{
			int32 i;
			for (i = 0; i < num_rects; ++i)
			{
				if (con.x + rects[i].w > con.width)
				{
					con.x = 0;
					con.y = con.bottom_y;
				}
				if (con.y + rects[i].h > con.height)
					break;
				rects[i].x = con.x;
				rects[i].y = con.y;
				rects[i].was_packed = true;
				con.x += rects[i].w;
				if (con.y + rects[i].h > con.bottom_y)
					con.bottom_y = con.y + rects[i].h;
			}
			for (; i < num_rects; ++i)
				rects[i].was_packed = false;
		}
#endif

		 //////////////////////////////////////////////////////////////////////////////
		 //
		 // bitmap baking
		 //
		 // This is SUPER-AWESOME (tm Ryan Gordon) packing using stb_rect_pack.h. If
		 // stb_rect_pack.h isn't available, it uses the BakeFontBitmap strategy.

		public static int32 stbtt_PackBegin(stbtt_pack_context* spc, uint8* pixels, int32 pw, int32 ph, int32 stride_in_bytes, int32 padding, void* alloc_context)
		{
			stbrp_context* context = (stbrp_context*)STBTT_malloc!(sizeof(stbrp_context), alloc_context);
			int32 num_nodes = pw - padding;
			stbrp_node* nodes = (stbrp_node*)STBTT_malloc!(sizeof(stbrp_node) * num_nodes, alloc_context);

			if (context == null || nodes == null)
			{
				if (context != null) STBTT_free!(context, alloc_context);
				if (nodes != null) STBTT_free!(nodes, alloc_context);
				return 0;
			}

			spc.user_allocator_context = alloc_context;
			spc.width = pw;
			spc.height = ph;
			spc.pixels = pixels;
			spc.pack_info = context;
			spc.nodes = nodes;
			spc.padding = padding;
			spc.stride_in_bytes = stride_in_bytes != 0 ? stride_in_bytes : pw;
			spc.h_oversample = 1;
			spc.v_oversample = 1;
			spc.skip_missing = false;

			stbrp_init_target(context, pw - padding, ph - padding, nodes, num_nodes);

			if (pixels != null)
				STBTT_memset!(pixels, 0, pw * ph);// background of 0 around pixels

			return 1;
		}

		public static void stbtt_PackEnd(stbtt_pack_context* spc)
		{
			STBTT_free!(spc.nodes, spc.user_allocator_context);
			STBTT_free!(spc.pack_info, spc.user_allocator_context);
		}

		public static void stbtt_PackSetOversampling(stbtt_pack_context* spc, uint32 h_oversample, uint32 v_oversample)
		{
			STBTT_assert!(h_oversample <= STBTT_MAX_OVERSAMPLE);
			STBTT_assert!(v_oversample <= STBTT_MAX_OVERSAMPLE);
			if (h_oversample <= STBTT_MAX_OVERSAMPLE)
				spc.h_oversample = h_oversample;
			if (v_oversample <= STBTT_MAX_OVERSAMPLE)
				spc.v_oversample = v_oversample;
		}

		public static void stbtt_PackSetSkipMissingCodepoints(stbtt_pack_context* spc, bool skip)
		{
			spc.skip_missing = skip;
		}

		const int STBTT__OVER_MASK = (STBTT_MAX_OVERSAMPLE - 1);

		static void stbtt__h_prefilter(uint8* pixels, int32 w, int32 h, int32 stride_in_bytes, uint32 kernel_width)
		{
			var pixels;
			uint8[STBTT_MAX_OVERSAMPLE] buffer = default;
			int32 safe_w = w - (.)kernel_width;
			int32 j;
		   //STBTT_memset!(buffer, 0, STBTT_MAX_OVERSAMPLE); // suppress bogus warning from VS2013 -analyze
			for (j = 0; j < h; ++j)
			{
				int32 i;
				uint32 total;
				STBTT_memset!(&buffer[0], 0, (int32)kernel_width);

				total = 0;

				// make kernel_width a constant in common cases so compiler can optimize out the divide
				switch (kernel_width) {
				case 2:
					for (i = 0; i <= safe_w; ++i)
					{
						total += (uint32)pixels[i] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i];
						pixels[i] = (uint8)(total / 2);
					}
					break;
				case 3:
					for (i = 0; i <= safe_w; ++i)
					{
						total += (uint32)pixels[i] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i];
						pixels[i] = (uint8)(total / 3);
					}
					break;
				case 4:
					for (i = 0; i <= safe_w; ++i)
					{
						total += (uint32)pixels[i] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i];
						pixels[i] = (uint8)(total / 4);
					}
					break;
				case 5:
					for (i = 0; i <= safe_w; ++i)
					{
						total += (uint32)pixels[i] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i];
						pixels[i] = (uint8)(total / 5);
					}
					break;
				default:
					for (i = 0; i <= safe_w; ++i)
					{
						total += (uint32)pixels[i] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i];
						pixels[i] = (uint8)(total / kernel_width);
					}
					break;
				}

				for (; i < w; ++i)
				{
					STBTT_assert!(pixels[i] == 0);
					total -= buffer[i & STBTT__OVER_MASK];
					pixels[i] = (uint8)(total / kernel_width);
				}

				pixels += stride_in_bytes;
			}
		}

		static void stbtt__v_prefilter(uint8* pixels, int32 w, int32 h, int32 stride_in_bytes, uint32 kernel_width)
		{
			var pixels;
			uint8[STBTT_MAX_OVERSAMPLE] buffer = default;
			int32 safe_h = h - (.)kernel_width;
			int32 j;
		   //STBTT_memset(buffer, 0, STBTT_MAX_OVERSAMPLE); // suppress bogus warning from VS2013 -analyze
			for (j = 0; j < w; ++j)
			{
				int32 i;
				uint32 total;
				STBTT_memset!(&buffer[0], 0, (int32)kernel_width);

				total = 0;

				// make kernel_width a constant in common cases so compiler can optimize out the divide
				switch (kernel_width) {
				case 2:
					for (i = 0; i <= safe_h; ++i)
					{
						total += (uint32)pixels[i * stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i * stride_in_bytes];
						pixels[i * stride_in_bytes] = (uint8)(total / 2);
					}
					break;
				case 3:
					for (i = 0; i <= safe_h; ++i)
					{
						total += (uint32)pixels[i * stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i * stride_in_bytes];
						pixels[i * stride_in_bytes] = (uint8)(total / 3);
					}
					break;
				case 4:
					for (i = 0; i <= safe_h; ++i)
					{
						total += (uint32)pixels[i * stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i * stride_in_bytes];
						pixels[i * stride_in_bytes] = (uint8)(total / 4);
					}
					break;
				case 5:
					for (i = 0; i <= safe_h; ++i)
					{
						total += (uint32)pixels[i * stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i * stride_in_bytes];
						pixels[i * stride_in_bytes] = (uint8)(total / 5);
					}
					break;
				default:
					for (i = 0; i <= safe_h; ++i)
					{
						total += (uint32)pixels[i * stride_in_bytes] - buffer[i & STBTT__OVER_MASK];
						buffer[(i + (.)kernel_width) & STBTT__OVER_MASK] = pixels[i * stride_in_bytes];
						pixels[i * stride_in_bytes] = (uint8)(total / kernel_width);
					}
					break;
				}

				for (; i < h; ++i)
				{
					STBTT_assert!(pixels[i * stride_in_bytes] == 0);
					total -= buffer[i & STBTT__OVER_MASK];
					pixels[i * stride_in_bytes] = (uint8)(total / kernel_width);
				}

				pixels += 1;
			}
		}

		static float stbtt__oversample_shift(int32 oversample)
		{
			if (oversample == 0)
				return 0.0f;

			// The prefilter is a box filter of width "oversample",
			// which shifts phase by (oversample - 1)/2 pixels in
			// oversampled space. We want to shift in the opposite
			// direction to counter this.
			return (float)(-(oversample - 1) / (2.0f * (float)oversample));
		}

		 // rects array must be big enough to accommodate all characters in the given ranges
		public static int32 stbtt_PackFontRangesGatherRects(stbtt_pack_context* spc, stbtt_fontinfo* info, stbtt_pack_range* ranges, int32 num_ranges, stbrp_rect* rects)
		{
			int32 i, j, k;
			bool missing_glyph_added = false;

			k = 0;
			for (i = 0; i < num_ranges; ++i)
			{
				float fh = ranges[i].font_size;
				float scale = fh > 0 ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
				ranges[i].h_oversample = (uint8)spc.h_oversample;
				ranges[i].v_oversample = (uint8)spc.v_oversample;
				for (j = 0; j < ranges[i].num_chars; ++j)
				{
					int32 x0 = ?, y0 = ?, x1 = ?, y1 = ?;
					int32 codepoint = ranges[i].array_of_unicode_codepoints == null ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
					int32 glyph = stbtt_FindGlyphIndex(info, codepoint);
					if (glyph == 0 && (spc.skip_missing || missing_glyph_added))
					{
						rects[k].w = rects[k].h = 0;
					} else
					{
						stbtt_GetGlyphBitmapBoxSubpixel(info, glyph,
							scale * spc.h_oversample,
							scale * spc.v_oversample,
							0, 0,
							&x0, &y0, &x1, &y1);
						rects[k].w = (stbrp_coord)(x1 - x0 + spc.padding + (.)spc.h_oversample - 1);
						rects[k].h = (stbrp_coord)(y1 - y0 + spc.padding + (.)spc.v_oversample - 1);
						if (glyph == 0)
							missing_glyph_added = true;
					}
					++k;
				}
			}

			return k;
		}

		public static void stbtt_MakeGlyphBitmapSubpixelPrefilter(stbtt_fontinfo* info, uint8* output, int32 out_w, int32 out_h, int32 out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int32 prefilter_x, int32 prefilter_y, float* sub_x, float* sub_y, int32 glyph)
		{
			stbtt_MakeGlyphBitmapSubpixel(info,
				output,
				out_w - (prefilter_x - 1),
				out_h - (prefilter_y - 1),
				out_stride,
				scale_x,
				scale_y,
				shift_x,
				shift_y,
				glyph);

			if (prefilter_x > 1)
				stbtt__h_prefilter(output, out_w, out_h, out_stride, (.)prefilter_x);

			if (prefilter_y > 1)
				stbtt__v_prefilter(output, out_w, out_h, out_stride, (.)prefilter_y);

			*sub_x = stbtt__oversample_shift(prefilter_x);
			*sub_y = stbtt__oversample_shift(prefilter_y);
		}

		 // rects array must be big enough to accommodate all characters in the given ranges
		public static int32 stbtt_PackFontRangesRenderIntoRects(stbtt_pack_context* spc, stbtt_fontinfo* info, stbtt_pack_range* ranges, int32 num_ranges, stbrp_rect* rects)
		{
			int32 i, j, k, missing_glyph = -1, return_value = 1;

			// save current values
			int32 old_h_over = (.)spc.h_oversample;
			int32 old_v_over = (.)spc.v_oversample;

			k = 0;
			for (i = 0; i < num_ranges; ++i)
			{
				float fh = ranges[i].font_size;
				float scale = fh > 0 ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
				float recip_h, recip_v, sub_x, sub_y;
				spc.h_oversample = ranges[i].h_oversample;
				spc.v_oversample = ranges[i].v_oversample;
				recip_h = 1.0f / spc.h_oversample;
				recip_v = 1.0f / spc.v_oversample;
				sub_x = stbtt__oversample_shift((.)spc.h_oversample);
				sub_y = stbtt__oversample_shift((.)spc.v_oversample);
				for (j = 0; j < ranges[i].num_chars; ++j)
				{
					stbrp_rect* r = &rects[k];
					if (r.was_packed && r.w != 0 && r.h != 0)
					{
						stbtt_packedchar* bc = &ranges[i].chardata_for_range[j];
						int32 advance = ?, lsb, x0 = ?, y0 = ?, x1 = ?, y1 = ?;
						int32 codepoint = ranges[i].array_of_unicode_codepoints == null ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
						int32 glyph = stbtt_FindGlyphIndex(info, codepoint);
						stbrp_coord pad = (stbrp_coord)spc.padding;

						// pad on left and top
						r.x += pad;
						r.y += pad;
						r.w -= pad;
						r.h -= pad;
						stbtt_GetGlyphHMetrics(info, glyph, &advance, &lsb);
						stbtt_GetGlyphBitmapBox(info, glyph,
							scale * spc.h_oversample,
							scale * spc.v_oversample,
							&x0, &y0, &x1, &y1);
						stbtt_MakeGlyphBitmapSubpixel(info,
							spc.pixels + r.x + r.y * spc.stride_in_bytes,
							r.w - (.)spc.h_oversample + 1,
							r.h - (.)spc.v_oversample + 1,
							spc.stride_in_bytes,
							scale * spc.h_oversample,
							scale * spc.v_oversample,
							0, 0,
							glyph);

						if (spc.h_oversample > 1)
							stbtt__h_prefilter(spc.pixels + r.x + r.y * spc.stride_in_bytes,
								r.w, r.h, spc.stride_in_bytes,
								spc.h_oversample);

						if (spc.v_oversample > 1)
							stbtt__v_prefilter(spc.pixels + r.x + r.y * spc.stride_in_bytes,
								r.w, r.h, spc.stride_in_bytes,
								spc.v_oversample);

						bc.x0 = (.)r.x;
						bc.y0 = (.)r.y;
						bc.x1 = (.)(r.x + r.w);
						bc.y1 = (.)(r.y + r.h);
						bc.xadvance = scale * advance;
						bc.xoff = (float)x0 * recip_h + sub_x;
						bc.yoff = (float)y0 * recip_v + sub_y;
						bc.xoff2 = (x0 + r.w) * recip_h + sub_x;
						bc.yoff2 = (y0 + r.h) * recip_v + sub_y;

						if (glyph == 0)
							missing_glyph = j;
					} else if (spc.skip_missing) {
						return_value = 0;
					} else if (r.was_packed && r.w == 0 && r.h == 0 && missing_glyph >= 0) {
						ranges[i].chardata_for_range[j] = ranges[i].chardata_for_range[missing_glyph];
					} else {
						return_value = 0;// if any fail, report failure
					}

					++k;
				}
			}

			// restore original values
			spc.h_oversample = (.)old_h_over;
			spc.v_oversample = (.)old_v_over;

			return return_value;
		}

		public static void stbtt_PackFontRangesPackRects(stbtt_pack_context* spc, stbrp_rect* rects, int32 num_rects)
		{
			stbrp_pack_rects((stbrp_context*)spc.pack_info, rects, num_rects);
		}

		public static int32 stbtt_PackFontRanges(stbtt_pack_context* spc, uint8* fontdata, int32 font_index, stbtt_pack_range* ranges, int32 num_ranges)
		{
			stbtt_fontinfo info;
			int32 i, j, n, return_value = 1;
			//stbrp_context *context = (stbrp_context *) spc.pack_info;
			stbrp_rect* rects;

			// flag all characters as NOT packed
			for (i = 0; i < num_ranges; ++i)
				for (j = 0; j < ranges[i].num_chars; ++j)
					ranges[i].chardata_for_range[j].x0 =
						ranges[i].chardata_for_range[j].y0 =
						ranges[i].chardata_for_range[j].x1 =
						ranges[i].chardata_for_range[j].y1 = 0;

			n = 0;
			for (i = 0; i < num_ranges; ++i)
				n += ranges[i].num_chars;

			rects = (stbrp_rect*)STBTT_malloc!(sizeof(stbrp_rect) * n, spc.user_allocator_context);
			if (rects == null)
				return 0;

			info.userdata = spc.user_allocator_context;
			stbtt_InitFont(&info, fontdata, stbtt_GetFontOffsetForIndex(fontdata, font_index));

			n = stbtt_PackFontRangesGatherRects(spc, &info, ranges, num_ranges, rects);

			stbtt_PackFontRangesPackRects(spc, rects, n);

			return_value = stbtt_PackFontRangesRenderIntoRects(spc, &info, ranges, num_ranges, rects);

			STBTT_free!(rects, spc.user_allocator_context);
			return return_value;
		}

		public static int32 stbtt_PackFontRange(stbtt_pack_context* spc, uint8* fontdata, int32 font_index, float font_size,
			int32 first_unicode_codepoint_in_range, int32 num_chars_in_range, stbtt_packedchar* chardata_for_range)
		{
			stbtt_pack_range range;
			range.first_unicode_codepoint_in_range = first_unicode_codepoint_in_range;
			range.array_of_unicode_codepoints = null;
			range.num_chars = num_chars_in_range;
			range.chardata_for_range = chardata_for_range;
			range.font_size = font_size;
			return stbtt_PackFontRanges(spc, fontdata, font_index, &range, 1);
		}

		public static void stbtt_GetScaledFontVMetrics(uint8* fontdata, int32 index, float size, float* ascent, float* descent, float* lineGap)
		{
			int32 i_ascent = ?, i_descent = ?, i_lineGap = ?;
			float scale;
			stbtt_fontinfo info;
			stbtt_InitFont(&info, fontdata, stbtt_GetFontOffsetForIndex(fontdata, index));
			scale = size > 0 ? stbtt_ScaleForPixelHeight(&info, size) : stbtt_ScaleForMappingEmToPixels(&info, -size);
			stbtt_GetFontVMetrics(&info, &i_ascent, &i_descent, &i_lineGap);
			*ascent = (float)i_ascent * scale;
			*descent = (float)i_descent * scale;
			*lineGap = (float)i_lineGap * scale;
		}

		public static void stbtt_GetPackedQuad(stbtt_packedchar* chardata, int32 pw, int32 ph, int32 char_index, float* xpos, float* ypos, stbtt_aligned_quad* q, bool align_to_integer)
		{
			float ipw = 1.0f / pw, iph = 1.0f / ph;
			readonly stbtt_packedchar* b = chardata + char_index;

			if (align_to_integer)
			{
				float x = (float)STBTT_ifloor!((*xpos + b.xoff) + 0.5f);
				float y = (float)STBTT_ifloor!((*ypos + b.yoff) + 0.5f);
				q.x0 = x;
				q.y0 = y;
				q.x1 = x + b.xoff2 - b.xoff;
				q.y1 = y + b.yoff2 - b.yoff;
			} else {
				q.x0 = *xpos + b.xoff;
				q.y0 = *ypos + b.yoff;
				q.x1 = *xpos + b.xoff2;
				q.y1 = *ypos + b.yoff2;
			}

			q.s0 = b.x0 * ipw;
			q.t0 = b.y0 * iph;
			q.s1 = b.x1 * ipw;
			q.t1 = b.y1 * iph;

			*xpos += b.xadvance;
		}

		 //////////////////////////////////////////////////////////////////////////////
		 //
		 // sdf computation
		 //

		static mixin STBTT_min(var a, var b)
		{
			((a) < (b) ? (a) : (b))
		}
		static mixin STBTT_max(var a, var b)
		{
			((a) < (b) ? (b) : (a))
		}

		static int32 stbtt__ray_intersect_bezier(float[2] orig, float[2] ray, float[2] q0, float[2] q1, float[2] q2, float[2][2] hits)
		{
			var hits;
			float q0perp = q0[1] * ray[0] - q0[0] * ray[1];
			float q1perp = q1[1] * ray[0] - q1[0] * ray[1];
			float q2perp = q2[1] * ray[0] - q2[0] * ray[1];
			float roperp = orig[1] * ray[0] - orig[0] * ray[1];

			float a = q0perp - 2 * q1perp + q2perp;
			float b = q1perp - q0perp;
			float c = q0perp - roperp;

			float s0 = 0.0f, s1 = 0.0f;
			int32 num_s = 0;

			if (a != 0.0)
			{
				float discr = b * b - a * c;
				if (discr > 0.0)
				{
					float rcpna = -1 / a;
					float d = (float)STBTT_sqrt!(discr);
					s0 = (b + d) * rcpna;
					s1 = (b - d) * rcpna;
					if (s0 >= 0.0 && s0 <= 1.0)
						num_s = 1;
					if (d > 0.0 && s1 >= 0.0 && s1 <= 1.0)
					{
						if (num_s == 0) s0 = s1;
						++num_s;
					}
				}
			} else {
			  // 2*b*s + c = 0
			  // s = -c / (2*b)
				s0 = c / (-2 * b);
				if (s0 >= 0.0 && s0 <= 1.0)
					num_s = 1;
			}

			if (num_s == 0)
				return 0;
			else
			{
				float rcp_len2 = 1 / (ray[0] * ray[0] + ray[1] * ray[1]);
				float rayn_x = ray[0] * rcp_len2, rayn_y = ray[1] * rcp_len2;

				float q0d = q0[0] * rayn_x + q0[1] * rayn_y;
				float q1d = q1[0] * rayn_x + q1[1] * rayn_y;
				float q2d = q2[0] * rayn_x + q2[1] * rayn_y;
				float rod = orig[0] * rayn_x + orig[1] * rayn_y;

				float q10d = q1d - q0d;
				float q20d = q2d - q0d;
				float q0rd = q0d - rod;

				hits[0][0] = q0rd + s0 * (2.0f - 2.0f * s0) * q10d + s0 * s0 * q20d;
				hits[0][1] = a * s0 + b;

				if (num_s > 1)
				{
					hits[1][0] = q0rd + s1 * (2.0f - 2.0f * s1) * q10d + s1 * s1 * q20d;
					hits[1][1] = a * s1 + b;
					return 2;
				} else {
					return 1;
				}
			}
		}

		[Inline]
		static bool equal(float* a, float* b)
		{
			return (a[0] == b[0] && a[1] == b[1]);
		}

		static int32 stbtt__compute_crossings_x(float x, float y, int32 nverts, stbtt_vertex* verts)
		{
			var y;
			int32 i;
			float[2] orig, ray = .(1, 0);
			float y_frac;
			int32 winding = 0;

		   // make sure y never passes through a vertex of the shape
			y_frac = (float)STBTT_fmod!(y, 1.0f);
			if (y_frac < 0.01f)
				y += 0.01f;
			else if (y_frac > 0.99f)
				y -= 0.01f;

			orig[0] = x;
			orig[1] = y;

		   // test a ray from (-infinity,y) to (x,y)
			for (i = 0; i < nverts; ++i)
			{
				if (verts[i].type == STBTT_vline)
				{
					int32 x0 = (int32)verts[i - 1].x, y0 = (int32)verts[i - 1].y;
					int32 x1 = (int32)verts[i].x, y1 = (int32)verts[i].y;
					if (y > STBTT_min!(y0, y1) && y < STBTT_max!(y0, y1) && x > STBTT_min!(x0, x1))
					{
						float x_inter = (y - y0) / (y1 - y0) * (x1 - x0) + x0;
						if (x_inter < x)
							winding += (y0 < y1) ? 1 : -1;
					}
				}
				if (verts[i].type == STBTT_vcurve)
				{
					int32 x0 = (int32)verts[i - 1].x, y0 = (int32)verts[i - 1].y;
					int32 x1 = (int32)verts[i].cx, y1 = (int32)verts[i].cy;
					int32 x2 = (int32)verts[i].x, y2 = (int32)verts[i].y;
					int32 ax = STBTT_min!(x0, STBTT_min!(x1, x2)), ay = STBTT_min!(y0, STBTT_min!(y1, y2));
					int32 by = STBTT_max!(y0, STBTT_max!(y1, y2));
					if (y > ay && y < by && x > ax)
					{
						float[2] q0, q1, q2;
						float[2][2] hits = default;
						q0[0] = (float)x0;
						q0[1] = (float)y0;
						q1[0] = (float)x1;
						q1[1] = (float)y1;
						q2[0] = (float)x2;
						q2[1] = (float)y2;
						if (equal(&q0[0], &q1[0]) || equal(&q1[0], &q2[0]))
						{
							x0 = (int32)verts[i - 1].x;
							y0 = (int32)verts[i - 1].y;
							x1 = (int32)verts[i].x;
							y1 = (int32)verts[i].y;
							if (y > STBTT_min!(y0, y1) && y < STBTT_max!(y0, y1) && x > STBTT_min!(x0, x1))
							{
								float x_inter = (y - y0) / (y1 - y0) * (x1 - x0) + x0;
								if (x_inter < x)
									winding += (y0 < y1) ? 1 : -1;
							}
						} else {
							int32 num_hits = stbtt__ray_intersect_bezier(orig, ray, q0, q1, q2, hits);
							if (num_hits >= 1)
								if (hits[0][0] < 0)
									winding += (hits[0][1] < 0 ? -1 : 1);
							if (num_hits >= 2)
								if (hits[1][0] < 0)
									winding += (hits[1][1] < 0 ? -1 : 1);
						}
					}
				}
			}
			return winding;
		}

		static float stbtt__cuberoot(float x)
		{
			if (x < 0)
				return -(float)STBTT_pow!(-x, 1.0f / 3.0f);
			else
				return (float)STBTT_pow!(x, 1.0f / 3.0f);
		}

		 // x^3 + a*x^2 + b*x + c = 0
		static int32 stbtt__solve_cubic(float a, float b, float c, float* r)
		{
			float s = -a / 3;
			float p = b - a * a / 3;
			float q = a * (2 * a * a - 9 * b) / 27 + c;
			float p3 = p * p * p;
			float d = q * q + 4 * p3 / 27;
			if (d >= 0)
			{
				float z = (float)STBTT_sqrt!(d);
				float u = (-q + z) / 2;
				float v = (-q - z) / 2;
				u = stbtt__cuberoot(u);
				v = stbtt__cuberoot(v);
				r[0] = s + u + v;
				return 1;
			} else {
				float u = (float)STBTT_sqrt!(-p / 3);
				float v = (float)STBTT_acos!(-STBTT_sqrt!(-27 / p3) * q / 2) / 3;// p3 must be negative, since d is
				// negative
				float m = (float)STBTT_cos!(v);
				float n = (float)STBTT_cos!(v - 3.141592 / 2) * 1.732050808f;
				r[0] = s + u * 2 * m;
				r[1] = s - u * (m + n);
				r[2] = s - u * (m - n);

				//STBTT_assert!( STBTT_fabs(((r[0]+a)*r[0]+b)*r[0]+c) < 0.05f);  // these asserts may not be safe at all scales, though they're in bezier t parameter units so maybe?
				//STBTT_assert!( STBTT_fabs(((r[1]+a)*r[1]+b)*r[1]+c) < 0.05f);
				//STBTT_assert!( STBTT_fabs(((r[2]+a)*r[2]+b)*r[2]+c) < 0.05f);
				return 3;
			}
		}

		public static uint8* stbtt_GetGlyphSDF(stbtt_fontinfo* info, float scale, int32 glyph, int32 padding, uint8 onedge_value, float pixel_dist_scale, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			float scale_x = scale, scale_y = scale;
			int32 ix0 = ?, iy0 = ?, ix1 = ?, iy1 = ?;
			int32 w, h;
			uint8* data;

			if (scale == 0) return null;

			stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale, scale, 0.0f, 0.0f, &ix0, &iy0, &ix1, &iy1);

			// if empty, return NULL
			if (ix0 == ix1 || iy0 == iy1)
				return null;

			ix0 -= padding;
			iy0 -= padding;
			ix1 += padding;
			iy1 += padding;

			w = (ix1 - ix0);
			h = (iy1 - iy0);

			if (width != null) *width = w;
			if (height != null) *height = h;
			if (xoff != null) *xoff = ix0;
			if (yoff != null) *yoff = iy0;

			// invert for y-downwards bitmaps
			scale_y = -scale_y;
			{
				int32 x, y, i, j;
				float* precompute;
				stbtt_vertex* verts = ?;
				int32 num_verts = stbtt_GetGlyphShape(info, glyph, &verts);
				data = (uint8*)STBTT_malloc!(w * h, info.userdata);
				precompute = (float*)STBTT_malloc!(num_verts * sizeof(float), info.userdata);

				for (i = 0,j = num_verts - 1; i < num_verts; j = i++)
				{
					if (verts[i].type == STBTT_vline)
					{
						float x0 = verts[i].x * scale_x, y0 = verts[i].y * scale_y;
						float x1 = verts[j].x * scale_x, y1 = verts[j].y * scale_y;
						float dist = (float)STBTT_sqrt!((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
						precompute[i] = (dist == 0) ? 0.0f : 1.0f / dist;
					} else if (verts[i].type == STBTT_vcurve) {
						float x2 = verts[j].x * scale_x, y2 = verts[j].y * scale_y;
						float x1 = verts[i].cx * scale_x, y1 = verts[i].cy * scale_y;
						float x0 = verts[i].x * scale_x, y0 = verts[i].y * scale_y;
						float bx = x0 - 2 * x1 + x2, by = y0 - 2 * y1 + y2;
						float len2 = bx * bx + by * by;
						if (len2 != 0.0f)
							precompute[i] = 1.0f / (bx * bx + by * by);
						else
							precompute[i] = 0.0f;
					} else
						precompute[i] = 0.0f;
				}

				for (y = iy0; y < iy1; ++y)
				{
					for (x = ix0; x < ix1; ++x)
					{
						float val;
						float min_dist = 999999.0f;
						float sx = (float)x + 0.5f;
						float sy = (float)y + 0.5f;
						float x_gspace = (sx / scale_x);
						float y_gspace = (sy / scale_y);

						int32 winding = stbtt__compute_crossings_x(x_gspace, y_gspace, num_verts, verts);// @OPTIMIZE:
						// this could just be a rasterization, but needs to be line vs. non-tesselated curves so a new
						// path

						for (i = 0; i < num_verts; ++i)
						{
							float x0 = verts[i].x * scale_x, y0 = verts[i].y * scale_y;

							if (verts[i].type == STBTT_vline && precompute[i] != 0.0f)
							{
								float x1 = verts[i - 1].x * scale_x, y1 = verts[i - 1].y * scale_y;

								float dist, dist2 = (x0 - sx) * (x0 - sx) + (y0 - sy) * (y0 - sy);
								if (dist2 < min_dist * min_dist)
									min_dist = (float)STBTT_sqrt!(dist2);

								// coarse culling against bbox
								//if (sx > STBTT_min(x0,x1)-min_dist && sx < STBTT_max(x0,x1)+min_dist &&
								//    sy > STBTT_min(y0,y1)-min_dist && sy < STBTT_max(y0,y1)+min_dist)
								dist = (float)STBTT_fabs!((x1 - x0) * (y0 - sy) - (y1 - y0) * (x0 - sx)) * precompute[i];
								STBTT_assert!(i != 0);
								if (dist < min_dist)
								{
								   // check position along line
								   // x' = x0 + t*(x1-x0), y' = y0 + t*(y1-y0)
								   // minimize (x'-sx)*(x'-sx)+(y'-sy)*(y'-sy)
									float dx = x1 - x0, dy = y1 - y0;
									float px = x0 - sx, py = y0 - sy;
								   // minimize (px+t*dx)^2 + (py+t*dy)^2 = px*px + 2*px*dx*t + t^2*dx*dx + py*py + 2*py*dy*t + t^2*dy*dy
								   // derivative: 2*px*dx + 2*py*dy + (2*dx*dx+2*dy*dy)*t, set to 0 and solve
									float t = -(px * dx + py * dy) / (dx * dx + dy * dy);
									if (t >= 0.0f && t <= 1.0f)
										min_dist = dist;
								}
							} else if (verts[i].type == STBTT_vcurve) {
								float x2 = verts[i - 1].x * scale_x, y2 = verts[i - 1].y * scale_y;
								float x1 = verts[i].cx * scale_x, y1 = verts[i].cy * scale_y;
								float box_x0 = STBTT_min!(STBTT_min!(x0, x1), x2);
								float box_y0 = STBTT_min!(STBTT_min!(y0, y1), y2);
								float box_x1 = STBTT_max!(STBTT_max!(x0, x1), x2);
								float box_y1 = STBTT_max!(STBTT_max!(y0, y1), y2);
								// coarse culling against bbox to avoid computing cubic unnecessarily
								if (sx > box_x0 - min_dist && sx < box_x1 + min_dist && sy > box_y0 - min_dist && sy < box_y1 + min_dist)
								{
									int32 num = 0;
									float ax = x1 - x0, ay = y1 - y0;
									float bx = x0 - 2 * x1 + x2, by = y0 - 2 * y1 + y2;
									float mx = x0 - sx, my = y0 - sy;
									float[3] res = .(0.f, 0.f, 0.f);
									float px, py, t, it, dist2;
									float a_inv = precompute[i];
									if (a_inv == 0.0)
									{// if a_inv is 0, it's 2nd degree so use quadratic formula
										float a = 3 * (ax * bx + ay * by);
										float b = 2 * (ax * ax + ay * ay) + (mx * bx + my * by);
										float c = mx * ax + my * ay;
										if (a == 0.0)
										{// if a is 0, it's linear
											if (b != 0.0)
											{
												res[num++] = -c / b;
											}
										} else {
											float discriminant = b * b - 4 * a * c;
											if (discriminant < 0)
												num = 0;
											else
											{
												float root = (float)STBTT_sqrt!(discriminant);
												res[0] = (-b - root) / (2 * a);
												res[1] = (-b + root) / (2 * a);
												num = 2;// don't bother distinguishing 1-solution case, as code below
											// will still work
											}
										}
									} else {
										float b = 3 * (ax * bx + ay * by) * a_inv;// could precompute this as it doesn't
										// depend on sample point
										float c = (2 * (ax * ax + ay * ay) + (mx * bx + my * by)) * a_inv;
										float d = (mx * ax + my * ay) * a_inv;
										num = stbtt__solve_cubic(b, c, d, &res[0]);
									}
									dist2 = (x0 - sx) * (x0 - sx) + (y0 - sy) * (y0 - sy);
									if (dist2 < min_dist * min_dist)
										min_dist = (float)STBTT_sqrt!(dist2);

									if (num >= 1 && res[0] >= 0.0f && res[0] <= 1.0f)
									{
										t = res[0]; it = 1.0f - t;
										px = it * it * x0 + 2 * t * it * x1 + t * t * x2;
										py = it * it * y0 + 2 * t * it * y1 + t * t * y2;
										dist2 = (px - sx) * (px - sx) + (py - sy) * (py - sy);
										if (dist2 < min_dist * min_dist)
											min_dist = (float)STBTT_sqrt!(dist2);
									}
									if (num >= 2 && res[1] >= 0.0f && res[1] <= 1.0f)
									{
										t = res[1]; it = 1.0f - t;
										px = it * it * x0 + 2 * t * it * x1 + t * t * x2;
										py = it * it * y0 + 2 * t * it * y1 + t * t * y2;
										dist2 = (px - sx) * (px - sx) + (py - sy) * (py - sy);
										if (dist2 < min_dist * min_dist)
											min_dist = (float)STBTT_sqrt!(dist2);
									}
									if (num >= 3 && res[2] >= 0.0f && res[2] <= 1.0f)
									{
										t = res[2]; it = 1.0f - t;
										px = it * it * x0 + 2 * t * it * x1 + t * t * x2;
										py = it * it * y0 + 2 * t * it * y1 + t * t * y2;
										dist2 = (px - sx) * (px - sx) + (py - sy) * (py - sy);
										if (dist2 < min_dist * min_dist)
											min_dist = (float)STBTT_sqrt!(dist2);
									}
								}
							}
						}
						if (winding == 0)
							min_dist = -min_dist;// if outside the shape, value is negative
						val = (int32)onedge_value + pixel_dist_scale * min_dist;
						if (val < 0)
							val = 0;
						else if (val > 255)
							val = 255;
						data[(y - iy0) * w + (x - ix0)] = (uint8)val;
					}
				}
				STBTT_free!(precompute, info.userdata);
				STBTT_free!(verts, info.userdata);
			}
			return data;
		}

		public static uint8* stbtt_GetCodepointSDF(stbtt_fontinfo* info, float scale, int32 codepoint, int32 padding, uint8 onedge_value, float pixel_dist_scale, int32* width, int32* height, int32* xoff, int32* yoff)
		{
			return stbtt_GetGlyphSDF(info, scale, stbtt_FindGlyphIndex(info, codepoint), padding, onedge_value, pixel_dist_scale, width, height, xoff, yoff);
		}

		public static void stbtt_FreeSDF(uint8* bitmap, void* userdata)
		{
			STBTT_free!(bitmap, userdata);
		}

		 //////////////////////////////////////////////////////////////////////////////
		 //
		 // font name matching -- recommended not to use this
		 //

		 // check if a utf8 string contains a prefix which is the utf16 string; if so return length of matching utf8 string
		static stbtt_int32 stbtt__CompareUTF8toUTF16_bigendian_prefix(stbtt_uint8* s1, stbtt_int32 len1, stbtt_uint8* s2, stbtt_int32 len2)
		{
			var s2, len2;
			stbtt_int32 i = 0;

		   // convert utf16 to utf8 and compare the results while converting
			while (len2 != 0)
			{
				stbtt_uint16 ch = ((uint16)s2[0]) * 256 + s2[1];
				if (ch < 0x80)
				{
					if (i >= len1) return -1;
					if (s1[i++] != ch) return -1;
				} else if (ch < 0x800) {
					if (i + 1 >= len1) return -1;
					if (s1[i++] != 0xc0 + (ch >> 6)) return -1;
					if (s1[i++] != 0x80 + (ch & 0x3f)) return -1;
				} else if (ch >= 0xd800 && ch < 0xdc00) {
					stbtt_uint32 c;
					stbtt_uint16 ch2 = ((uint16)s2[2]) * 256 + s2[3];
					if (i + 3 >= len1) return -1;
					c = ((ch - (uint16)0xd800) << 10) + (ch2 - (uint16)0xdc00) + (uint32)0x10000;
					if (s1[i++] != 0xf0 + (c >> 18)) return -1;
					if (s1[i++] != 0x80 + ((c >> 12) & 0x3f)) return -1;
					if (s1[i++] != 0x80 + ((c >> 6) & 0x3f)) return -1;
					if (s1[i++] != 0x80 + ((c) & 0x3f)) return -1;
					s2 += 2;// plus another 2 below
					len2 -= 2;
				} else if (ch >= 0xdc00 && ch < 0xe000) {
					return -1;
				} else {
					if (i + 2 >= len1) return -1;
					if (s1[i++] != 0xe0 + (ch >> 12)) return -1;
					if (s1[i++] != 0x80 + ((ch >> 6) & 0x3f)) return -1;
					if (s1[i++] != 0x80 + ((ch) & 0x3f)) return -1;
				}
				s2 += 2;
				len2 -= 2;
			}
			return i;
		}

		static bool stbtt_CompareUTF8toUTF16_bigendian_internal(char8* s1, int32 len1, char8* s2, int32 len2)
		{
			return len1 == stbtt__CompareUTF8toUTF16_bigendian_prefix((stbtt_uint8*)s1, len1, (stbtt_uint8*)s2, len2);
		}

		 // returns results in whatever encoding you request... but note that 2-byte encodings
		 // will be BIG-ENDIAN... use stbtt_CompareUTF8toUTF16_bigendian() to compare
		public static char8* stbtt_GetFontNameString(stbtt_fontinfo* font, int32* length, int32 platformID, int32 encodingID, int32 languageID, int32 nameID)
		{
			stbtt_int32 i, count, stringOffset;
			stbtt_uint8* fc = font.data;
			stbtt_uint32 offset = (.)font.fontstart;
			stbtt_uint32 nm = stbtt__find_table(fc, offset, "name");
			if (nm == 0) return null;

			count = ttUSHORT(fc + nm + 2);
			stringOffset = (.)nm + ttUSHORT(fc + nm + 4);
			for (i = 0; i < count; ++i)
			{
				stbtt_uint32 loc = nm + 6 + 12 * (.)i;
				if (platformID == ttUSHORT(fc + loc + 0) && encodingID == ttUSHORT(fc + loc + 2)
					&& languageID == ttUSHORT(fc + loc + 4) && nameID == ttUSHORT(fc + loc + 6))
				{
					*length = ttUSHORT(fc + loc + 8);
					return (char8*)(fc + stringOffset + ttUSHORT(fc + loc + 10));
				}
			}
			return null;
		}

		static bool stbtt__matchpair(stbtt_uint8* fc, stbtt_uint32 nm, stbtt_uint8* name, stbtt_int32 nlen, stbtt_int32 target_id, stbtt_int32 next_id)
		{
			stbtt_int32 i;
			stbtt_int32 count = ttUSHORT(fc + nm + 2);
			stbtt_int32 stringOffset = (.)nm + ttUSHORT(fc + nm + 4);

			for (i = 0; i < count; ++i)
			{
				stbtt_uint32 loc = nm + 6 + 12 * (.)i;
				stbtt_int32 id = ttUSHORT(fc + loc + 6);
				if (id == target_id)
				{
				   // find the encoding
					stbtt_int32 platform = ttUSHORT(fc + loc + 0), encoding = ttUSHORT(fc + loc + 2), language = ttUSHORT(fc + loc + 4);

				   // is this a Unicode encoding?
					if (platform == 0 || (platform == 3 && encoding == 1) || (platform == 3 && encoding == 10))
					{
						stbtt_int32 slen = ttUSHORT(fc + loc + 8);
						stbtt_int32 off = ttUSHORT(fc + loc + 10);

						// check if there's a prefix match
						stbtt_int32 matchlen = stbtt__CompareUTF8toUTF16_bigendian_prefix(name, nlen, fc + stringOffset + off, slen);
						if (matchlen >= 0)
						{
						   // check for target_id+1 immediately following, with same encoding & language
							if (i + 1 < count && ttUSHORT(fc + loc + 12 + 6) == next_id && ttUSHORT(fc + loc + 12) == platform && ttUSHORT(fc + loc + 12 + 2) == encoding && ttUSHORT(fc + loc + 12 + 4) == language)
							{
								slen = ttUSHORT(fc + loc + 12 + 8);
								off = ttUSHORT(fc + loc + 12 + 10);
								if (slen == 0)
								{
									if (matchlen == nlen)
										return true;
								} else if (matchlen < nlen && name[matchlen] == ' ') {
									++matchlen;
									if (stbtt_CompareUTF8toUTF16_bigendian_internal((char8*)(name + matchlen), nlen - matchlen, (char8*)(fc + stringOffset + off), slen))
										return true;
								}
							} else {
							  // if nothing immediately following
								if (matchlen == nlen)
									return true;
							}
						}
					}

				   // @TODO handle other encodings
				}
			}
			return false;
		}

		static bool stbtt__matches(stbtt_uint8* fc, stbtt_uint32 offset, stbtt_uint8* name, stbtt_int32 flags)
		{
			stbtt_int32 nlen = (stbtt_int32)STBTT_strlen!((char8*)name);
			stbtt_uint32 nm, hd;
			if (!stbtt__isfont(fc + offset)) return false;

			// check italics/bold/underline flags in macStyle...
			if (flags != 0)
			{
				hd = stbtt__find_table(fc, offset, "head");
				if ((ttUSHORT(fc + hd + 44) & 7) != (flags & 7)) return false;
			}

			nm = stbtt__find_table(fc, offset, "name");
			if (nm == 0) return false;

			if (flags != 0)
			{
			   // if we checked the macStyle flags, then just check the family and ignore the subfamily
				if (stbtt__matchpair(fc, nm, name, nlen, 16, -1)) return true;
				if (stbtt__matchpair(fc, nm, name, nlen, 1, -1)) return true;
				if (stbtt__matchpair(fc, nm, name, nlen, 3, -1)) return true;
			} else {
				if (stbtt__matchpair(fc, nm, name, nlen, 16, 17)) return true;
				if (stbtt__matchpair(fc, nm, name, nlen, 1, 2)) return true;
				if (stbtt__matchpair(fc, nm, name, nlen, 3, -1)) return true;
			}

			return false;
		}

		static int32 stbtt_FindMatchingFont_internal(uint8* font_collection, char8* name_utf8, stbtt_int32 flags)
		{
			stbtt_int32 i;
			for (i = 0;; ++i)
			{
				stbtt_int32 off = stbtt_GetFontOffsetForIndex(font_collection, i);
				if (off < 0) return off;
				if (stbtt__matches((stbtt_uint8*)font_collection, (.)off, (stbtt_uint8*)name_utf8, flags))
					return off;
			}
		}

		public static int32 stbtt_BakeFontBitmap(uint8* data, int32 offset,
			float pixel_height, uint8* pixels, int32 pw, int32 ph,
			int32 first_char, int32 num_chars, stbtt_bakedchar* chardata)
		{
			return stbtt_BakeFontBitmap_internal((uint8*)data, offset, pixel_height, pixels, pw, ph, first_char, num_chars, chardata);
		}

		public static int32 stbtt_GetFontOffsetForIndex(uint8* data, int32 index)
		{
			return stbtt_GetFontOffsetForIndex_internal((uint8*)data, index);
		}

		public static int32 stbtt_GetNumberOfFonts(uint8* data)
		{
			return stbtt_GetNumberOfFonts_internal((uint8*)data);
		}

		public static bool stbtt_InitFont(stbtt_fontinfo* info, uint8* data, int32 offset)
		{
			return stbtt_InitFont_internal(info, (uint8*)data, offset);
		}

		public static int32 stbtt_FindMatchingFont(uint8* fontdata, char8* name, int32 flags)
		{
			return stbtt_FindMatchingFont_internal((uint8*)fontdata, (char8*)name, flags);
		}

		public static bool stbtt_CompareUTF8toUTF16_bigendian(char8* s1, int32 len1, char8* s2, int32 len2)
		{
			return stbtt_CompareUTF8toUTF16_bigendian_internal((char8*)s1, len1, (char8*)s2, len2);
		}
	}
}

/*
------------------------------------------------------------------------------
This software is available under 2 licenses -- choose whichever you prefer.
------------------------------------------------------------------------------
ALTERNATIVE A - MIT License
Copyright (c) 2017 Sean Barrett
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
ALTERNATIVE B - Public Domain (www.unlicense.org)
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
------------------------------------------------------------------------------
*/