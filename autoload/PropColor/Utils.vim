vim9script

var default_extractors = [
    {
		name: 'hex',
        pattern: '\v#[0-9a-fA-F]{6}',
        extract: (m) => m[0],
        format: (r, g, b, a) => printf("#%02x%02x%02x", r, g, b),
		filetypes: []
    },
	{
		name: 'hexAlpha',
        pattern: '\v#[0-9a-fA-F]{8}',
		extract: (m) => '#' .. m[0][2 :],
		format: (r, g, b, a) => printf("0x%02x%02x%02x%02x", r, g, b, a),
		filetypes: []
	},
	{
		name: 'rgb',
        pattern: '\vrgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)',
        extract: (m) => printf("#%02x%02x%02x", str2nr(m[1]), str2nr(m[2]), str2nr(m[3])),
        format: (r, g, b, a) => printf("rgb(%d, %d, %d)", r, g, b),
		filetypes: []
    },
	{
		name: 'rgba',
        pattern: '\vrgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(,\s*[0-9.]+\s*)?\)',
        extract: (m) => printf("#%02x%02x%02x", str2nr(m[1]), str2nr(m[2]), str2nr(m[3])),
        format: (r, g, b, a) => printf("rgba(%d, %d, %d, %.1f)", r, g, b, a / 255.0),
		filetypes: []
    },
]

var combined_extractor_cache: list<dict<any>> = null_list

export def GetAllExtractors(): list<dict<any>>
	if combined_extractor_cache != null_list
		return combined_extractor_cache
	endif

	const disabled_names = get(g:, 'prop_colors_disable', [])

    var extractors = default_extractors->filter((_, v) => {
        return index(disabled_names, v.name) == -1
    })
	var custom_extractors = get(g:, 'prop_colors_custom', [])
	for custom in custom_extractors
		extractors += [custom]
	endfor 
	combined_extractor_cache = extractors
	return extractors
enddef


var combined_pattern_cache: string = null_string

export def GetCombinedPattern(): string
	if combined_pattern_cache != null_string
		return combined_pattern_cache
	endif
	var pattern = GetAllExtractors()->mapnew((_, v) => v.pattern)->join('|') 
	var regex_opti = substitute(pattern, '\\\@<!(', '%(', 'g')
	combined_pattern_cache = '\v(' .. regex_opti .. ')'
	return combined_pattern_cache
enddef

var extractors_by_ft_cache: dict<list<dict<any>>> = {}

export def GetExtractorsFor(filetype: string): list<dict<any>>
    if has_key(extractors_by_ft_cache, filetype)
        return extractors_by_ft_cache[filetype]
    endif

    var filtered = GetAllExtractors()->filter((_, ex) => {
        return !has_key(ex, 'filetypes') 
            || empty(ex.filetypes) 
            || index(ex.filetypes, filetype) != -1
    })

    extractors_by_ft_cache[filetype] = filtered
    return filtered
enddef
