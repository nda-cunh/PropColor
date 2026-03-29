vim9script

var default_extractors = [
    {
        pattern: '\v#[0-9a-fA-F]{6}',
        extract: (m) => m[0],
        format: (r, g, b, a) => printf("#%02x%02x%02x", r, g, b)
    },
    {
        pattern: '\v0x[0-9a-fA-F]{6}',
        extract: (m) => '#' .. m[0][2 :],
        format: (r, g, b, a) => printf("0x%02x%02x%02x", r, g, b)
    },
	{
        pattern: '\vrgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(,\s*[0-9.]+\s*)?\)',
        extract: (m) => printf("#%02x%02x%02x", str2nr(m[1]), str2nr(m[2]), str2nr(m[3])),
        format: (r, g, b, a) => printf("rgb(%d, %d, %d)", r, g, b)
    },
    {
		pattern: '\vVec4\{X:\s*([0-9.]+),\s*Y:\s*([0-9.]+),\s*Z:\s*([0-9.]+)(,\s*W:\s*[0-9.]+)?\}',
        extract: (m) => printf("#%02x%02x%02x%02x",
		float2nr(str2float(m[1]) * 255),
		float2nr(str2float(m[2]) * 255),
		float2nr(str2float(m[3]) * 255),
		float2nr(str2float(m[4]) * 255)
		),
        format: (r, g, b, a) => printf("Vec4{X: %.1f, Y: %.1f, Z: %.1f, W: %.1f}", r / 255.0, g / 255.0, b / 255.0, a / 255.0)
    }
]


export def GetAllExtractors(): list<dict<any>>
	return default_extractors
enddef


export def GetCombinedPattern(): string
    return '\v(' .. GetAllExtractors()->mapnew((_, v) => v.pattern)->join('|') .. ')'
enddef
