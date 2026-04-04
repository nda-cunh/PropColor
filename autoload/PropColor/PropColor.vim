vim9script

import autoload './Utils.vim' as Utils

export def RefreshAllColors()
	for i in range(1, line('$'))
		ProcessSingleLine(i)
	endfor
enddef

export def InitColorListener()
	if &buftype != '' || &buflisted == false 
        return
    endif

	if get(b:, 'PropColor_Enabled', false) == false 
		listener_add('ColorListener', bufnr('%'))
        b:PropColor_Enabled = true
	endif

	const bufnr = bufnr('%')
	const total_lines = line('$')

    for lnum in range(1, total_lines)
        ProcessSingleLine(lnum, bufnr)
    endfor
	# ScanByChunks(bufnr, 1, total_lines, 500)
enddef

def ScanByChunks(buf: number, start_lnum: number, max_lnum: number, chunk_size: number)
    if !bufexists(buf) | return | endif

    var current = start_lnum
    var end_idx = min([current + chunk_size - 1, max_lnum])

    for lnum in range(current, end_idx)
        ProcessSingleLine(lnum, buf)
    endfor

    if end_idx < max_lnum
        timer_start(20, (_) => {
            ScanByChunks(buf, end_idx + 1, max_lnum, chunk_size)
        })
    endif
enddef

#######################
#  Private Functions  #
#######################

export def ReinitColors()
	# remove all prop_type
	for type in keys(known_types)
		prop_type_delete(type)
	endfor
	known_types = {}
	# relaunch
	RefreshAllColors()
enddef


var known_types: dict<bool> = {}
const PREFIX = "inline_color_"
const RPREFIX = '^' .. PREFIX
const COLOR_PROP_ID = 2000


def ProcessSingleLine(lnum: number, buffer: number = bufnr('%'))
    const style = get(g:, 'prop_colors_style', 'both')
    if style == 'none' | return | endif

    const current = getbufline(buffer, lnum)[0]
    if empty(current) | return | endif

    const to_remove = prop_list(lnum, {bufnr: buffer})->filter((_, p) => has_key(p, 'type') && p.type =~ RPREFIX)
    for p in to_remove
        silent! prop_remove({type: p.type, bufnr: buffer}, lnum)
    endfor

    const combined_pattern = Utils.GetCombinedPattern()
    
    var last_col = 0
	const filetype = &filetype

    while true
        var res = matchstrpos(current, combined_pattern, last_col)
        if res[1] == -1 | break | endif

        var raw_text = res[0]
        var starts = res[1]
        var ends = res[2]
        var hex = ""

        for extractor in Utils.GetAllExtractors()
            # IMPORTANT: matchlist permet de récupérer les groupes (X, Y, Z)
            var m = matchlist(raw_text, extractor.pattern)
			# if the filetype of this buffer is bad, skip it
			# if filetypes is [] , match all
			if has_key(extractor, 'filetypes') && len(extractor.filetypes) > 0 && index(extractor.filetypes, filetype) == -1
				continue
			endif
            if !empty(m)
                hex = extractor.extract(m)
                break
            endif
        endfor

        if !empty(hex)
			# if hex as alpha channel, remove it for the tag
			if len(hex) > 7 && hex[0] == '#'
				hex = hex[: 6]
			endif

            const col_tag = PREFIX .. hex[1 :]
            
            # --- HIGHLIGHT ---
            if !has_key(known_types, col_tag)
                if prop_type_get(col_tag) == {}
                    execute $"highlight {col_tag} guifg={hex} gui=bold"
                    prop_type_add(col_tag, {highlight: col_tag})
                endif
                known_types[col_tag] = true
            endif

            # --- PROP ADD ---
            if style == 'both' || style == 'icon'
                prop_add(lnum, starts + 1, {
                    text: "● ", 
                    type: col_tag, 
                    id: COLOR_PROP_ID, 
                    priority: 10,
                    bufnr: buffer
                })
            endif
            
            if style == 'both' || style == 'text'
                prop_add(lnum, starts + 1, {
                    type: col_tag,
                    id: COLOR_PROP_ID,
                    length: ends - starts,
                    priority: 10,
                    bufnr: buffer
                })
            endif
        endif

        last_col = ends
    endwhile
enddef


def ColorListener(buf: number, startline: number, endline: number, added: number, changes: list<any>)
    var last_line = line('$')
    for lnum in range(startline, endline + added - 1)
        if lnum >= 1 && lnum <= last_line
            ProcessSingleLine(lnum)
        endif
    endfor
enddef
