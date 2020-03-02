" Copyright (c) 2020 Cong Wang
" 
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
" 
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


" If already loaded, we're done...
if exists("loaded_SmartFold")
    finish
endif
let loaded_SmartFold = 1


let s:cpo_save = &cpo
set cpo&vim


function smartfold#run()
    " Set foldmethod to be manual...
    set fdm=manual

    " Record where search starts...
    let s:current_cusor = getpos('.')

    " Get the search keyword...
    call setpos('.',[0,1,1,0])
    let s:search_term_orig = input("Search for: ")

    " Empty string...
    if empty(s:search_term_orig) 
        call setpos('.',s:current_cusor)
        redraw
        echo "No string to search!"
        return 
    endif

    " Initialize search...
    let s:search_term = '\<'.s:search_term_orig.'\>'
    let s:ln_init=1
    let s:ln_last=1
    let s:fold_position = []
    let s:ln_matched = search(s:search_term,'cW')

    " [debug purpose]
    let g:ln_matched = s:ln_matched

    " prime test if it is necessary to search for a complete string...
    if s:ln_matched == 0
        let s:search_term = deepcopy(s:search_term_orig)
        let s:ln_matched = search(s:search_term,'cW')

        if s:ln_matched == 0
            let s:ln_last = line('$')
            call setpos('.',s:current_cusor)
            redraw
            echo "No string {".s:search_term."} is found"
        endif
    endif

    " Record all matched positions...
    let s:fold_gaps = 0
    while s:ln_matched != 0
        if s:ln_matched - s:ln_last > s:fold_gaps 
            call add(s:fold_position,[s:ln_last,s:ln_matched-1])
        endif
        let s:ln_last = deepcopy(s:ln_matched+1) 
        " the search function here also moves the cursor 
        " that's how it ends the while conditional loop...
        let s:ln_matched = search(s:search_term,'W')
    endwhile

    " If match happened at the last line, do not add it...
    if s:ln_last < line('$')
        call add(s:fold_position,[s:ln_last,line('$')]) 
    endif

    " Reset all folds and start to fold all non-matched lines...
    execute 'normal! zE'  
    if len(s:fold_position) > 0

        for item in s:fold_position
            execute item[0].','.item[1].'fold'
        endfor
        
    endif

    let @/=s:search_term

    " Restore cursor position...
    call setpos('.',s:current_cusor)
endfunction

nnoremap [s :setlocal hls<CR>:call smartfold#run()<CR>


let &cpo = s:cpo_save
unlet s:cpo_save


finish
