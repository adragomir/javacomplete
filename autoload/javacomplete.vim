" Vim completion script    - hit 80% complete tasks
" Version:    0.77.2
" Language:    Java
" Maintainer:    cheng fang <fangread@yahoo.com.cn>
" Submaitainer: Victor Denisov <denisovenator@gmail.com>
" Last Change:    2007-09-26
" Copyright:    Copyright (C) 2006-2007 cheng fang. All rights reserved.
" Copyright:    Copyright (C) 2010 Victor Denisov. All rights reserved.
" License:    Vim License    (see vim's :help license)

" constants                            {{{1
" input context type
let s:CONTEXT_AFTER_DOT        = 1
let s:CONTEXT_METHOD_PARAM    = 2
let s:CONTEXT_IMPORT        = 3
let s:CONTEXT_IMPORT_STATIC    = 4
let s:CONTEXT_PACKAGE_DECL    = 6 
let s:CONTEXT_NEED_TYPE        = 7 
let s:CONTEXT_OTHER         = 0


let s:ARRAY_TYPE_MEMBERS = [
            \    {'kind': 'm',        'word': 'clone(',    'abbr': 'clone()',    'menu': 'Object clone()', },
            \    {'kind': 'm',        'word': 'equals(',    'abbr': 'equals()',    'menu': 'boolean equals(Object)', },
            \    {'kind': 'm',        'word': 'getClass(',    'abbr': 'getClass()',    'menu': 'Class Object.getClass()', },
            \    {'kind': 'm',        'word': 'hashCode(',    'abbr': 'hashCode()',    'menu': 'int hashCode()', },
            \    {'kind': 'f',        'word': 'length',                'menu': 'int'},
            \    {'kind': 'm',        'word': 'notify(',    'abbr': 'notify()',    'menu': 'void Object.notify()', },
            \    {'kind': 'm',        'word': 'notifyAll(',    'abbr': 'notifyAll()',    'menu': 'void Object.notifyAll()', },
            \    {'kind': 'm',        'word': 'toString(',    'abbr': 'toString()',    'menu': 'String toString()', },
            \    {'kind': 'm',        'word': 'wait(',    'abbr': 'wait()',    'menu': 'void Object.wait() throws InterruptedException', },
            \    {'kind': 'm', 'dup': 1, 'word': 'wait(',    'abbr': 'wait()',    'menu': 'void Object.wait(long timeout) throws InterruptedException', },
            \    {'kind': 'm', 'dup': 1, 'word': 'wait(',    'abbr': 'wait()',    'menu': 'void Object.wait(long timeout, int nanos) throws InterruptedException', }]

let s:ARRAY_TYPE_INFO = {'tag': 'CLASSDEF', 'name': '[', 'ctors': [], 
            \     'fields': [{'n': 'length', 'm': '1', 't': 'int'}],
            \     'methods':[
            \    {'n': 'clone',      'm': '1',        'r': 'Object',    'p': [],        'd': 'Object clone()'},
            \    {'n': 'equals',      'm': '1',        'r': 'boolean',    'p': ['Object'],    'd': 'boolean Object.equals(Object obj)'},
            \    {'n': 'getClass', 'm': '100010001',    'r': 'Class',    'p': [],        'd': 'Class Object.getClass()'},
            \    {'n': 'hashCode', 'm': '100000001',    'r': 'int',    'p': [],        'd': 'int Object.hashCode()'},
            \    {'n': 'notify',      'm': '100010001',    'r': 'void',    'p': [],        'd': 'void Object.notify()'},
            \    {'n': 'notifyAll','m': '100010001',    'r': 'void',    'p': [],        'd': 'void Object.notifyAll()'},
            \    {'n': 'toString', 'm': '1',         'r': 'String',    'p': [],        'd': 'String Object.toString()'},
            \    {'n': 'wait',      'm': '10001',        'r': 'void',    'p': [],        'd': 'void Object.wait() throws InterruptedException'},
            \    {'n': 'wait',      'm': '100010001',    'r': 'void',    'p': ['long'],        'd': 'void Object.wait(long timeout) throws InterruptedException'},
            \    {'n': 'wait',      'm': '10001',        'r': 'void',    'p': ['long','int'],    'd': 'void Object.wait(long timeout, int nanos) throws InterruptedException'},
            \    ]}

let s:PRIMITIVE_TYPE_INFO = {'tag': 'CLASSDEF', 'name': '!', 'fields': [{'n': 'class','m': '1','t': 'Class'}]}

let s:JSP_BUILTIN_OBJECTS = {'session':	'javax.servlet.http.HttpSession',
            \	'request':	'javax.servlet.http.HttpServletRequest',
            \	'response':	'javax.servlet.http.HttpServletResponse',
            \	'pageContext':	'javax.servlet.jsp.PageContext', 
            \	'application':	'javax.servlet.ServletContext',
            \	'config':	'javax.servlet.ServletConfig',
            \	'out':		'javax.servlet.jsp.JspWriter',
            \	'page':		'javax.servlet.jsp.HttpJspPage', }


let s:PRIMITIVE_TYPES    = ['boolean', 'byte', 'char', 'int', 'short', 'long', 'float', 'double']
let s:KEYWORDS_MODS    = ['public', 'private', 'protected', 'static', 'final', 'synchronized', 'volatile', 'transient', 'native', 'strictfp', 'abstract']
let s:KEYWORDS_TYPE    = ['class', 'interface', 'enum']
let s:KEYWORDS        = s:PRIMITIVE_TYPES + s:KEYWORDS_MODS + s:KEYWORDS_TYPE + ['super', 'this', 'void'] + ['assert', 'break', 'case', 'catch', 'const', 'continue', 'default', 'do', 'else', 'extends', 'finally', 'for', 'goto', 'if', 'implements', 'import', 'instanceof', 'interface', 'new', 'package', 'return', 'switch', 'throw', 'throws', 'try', 'while', 'true', 'false', 'null']

let s:PATH_SEP    = ':'
let s:FILE_SEP    = '/'
if has("win32") || has("win64") || has("win16") || has("dos32") || has("dos16")
    let s:PATH_SEP    = ';'
    let s:FILE_SEP    = '\'
endif

let s:RE_BRACKETS    = '\%(\s*\[\s*\]\)'
let s:RE_IDENTIFIER    = '[a-zA-Z_$][a-zA-Z0-9_$]*'
let s:RE_QUALID        = s:RE_IDENTIFIER. '\%(\s*\.\s*' .s:RE_IDENTIFIER. '\)*'

let s:RE_REFERENCE_TYPE    = s:RE_QUALID . s:RE_BRACKETS . '*'
let s:RE_TYPE        = s:RE_REFERENCE_TYPE

let s:RE_TYPE_ARGUMENT    = '\%(?\s\+\%(extends\|super\)\s\+\)\=' . s:RE_TYPE
let s:RE_TYPE_ARGUMENTS    = '<' . s:RE_TYPE_ARGUMENT . '\%(\s*,\s*' . s:RE_TYPE_ARGUMENT . '\)*>'
let s:RE_TYPE_WITH_ARGUMENTS_I    = s:RE_IDENTIFIER . '\s*' . s:RE_TYPE_ARGUMENTS
let s:RE_TYPE_WITH_ARGUMENTS    = s:RE_TYPE_WITH_ARGUMENTS_I . '\%(\s*' . s:RE_TYPE_WITH_ARGUMENTS_I . '\)*'

let s:RE_TYPE_MODS    = '\%(public\|protected\|private\|abstract\|static\|final\|strictfp\)'
let s:RE_TYPE_DECL_HEAD    = '\(class\|interface\|enum\)[ \t\n\r]\+'
let s:RE_TYPE_DECL    = '\<\C\(\%(' .s:RE_TYPE_MODS. '\s\+\)*\)' .s:RE_TYPE_DECL_HEAD. '\(' .s:RE_IDENTIFIER. '\)[< \t\n\r]'

let s:RE_ARRAY_TYPE    = '^\s*\(' .s:RE_QUALID . '\)\(' . s:RE_BRACKETS . '\+\)\s*$'
let s:RE_SELECT_OR_ACCESS    = '^\s*\(' . s:RE_IDENTIFIER . '\)\s*\(\[.*\]\)\=\s*$'
let s:RE_ARRAY_ACCESS    = '^\s*\(' . s:RE_IDENTIFIER . '\)\s*\(\[.*\]\)\+\s*$'
let s:RE_CASTING    = '^\s*(\(' .s:RE_QUALID. '\))\s*\(' . s:RE_IDENTIFIER . '\)\>'

let s:RE_KEYWORDS    = '\<\%(' . join(s:KEYWORDS, '\|') . '\)\>'


" local variables                        {{{1
let b:context_type = s:CONTEXT_OTHER
let b:dotexpr = ''            " expression ends with '.'
let b:incomplete = ''            " incomplete word: 1. dotexpr.method(|) 2. new classname(|) 3. dotexpr.ab|, 4. ja|, 5. method(|
let b:errormsg = ''

" script variables                        {{{1
let s:cache = {}    " FQN -> member list, e.g. {'java.lang.StringBuffer': classinfo, 'java.util': packageinfo, '/dir/TopLevelClass.java': compilationUnit}
let s:files = {}    " source file path -> properties, e.g. {filekey: {'unit': compilationUnit, 'changedtick': tick, }}
let s:history = {}    " 
let g:nailgun_started = 0

" FindStart function for completion {{{1
function! s:FindStart()
    let s:et_whole = reltime()
    let start = col('.') - 1
    let s:log = []

    " reset enviroment
    let b:dotexpr = ''
    let b:incomplete = ''
    let b:context_type = s:CONTEXT_OTHER

    let statement = s:GetStatement()

    if statement =~ '[.0-9A-Za-z_]\s*$'
        let valid = 1
        if statement =~ '\.\s*$'
            let valid = statement =~ '[")0-9A-Za-z_\]]\s*\.\s*$' && statement !~ '\<\H\w\+\.\s*$' && statement !~ '\<\(abstract\|assert\|break\|case\|catch\|const\|continue\|default\|do\|else\|enum\|extends\|final\|finally\|for\|goto\|if\|implements\|import\|instanceof\|interface\|native\|new\|package\|private\|protected\|public\|return\|static\|strictfp\|switch\|synchronized\|throw\|throws\|transient\|try\|volatile\|while\|true\|false\|null\)\.\s*$'
        endif
        if !valid
            return -1
        endif

        let b:context_type = s:CONTEXT_AFTER_DOT

        " import or package declaration
        if statement =~# '^\s*\(import\|package\)\s\+'
            let statement = substitute(statement, '\s\+\.', '.', 'g')
            let statement = substitute(statement, '\.\s\+', '.', 'g')
            if statement =~ '^\s*import\s\+'
                let b:context_type = statement =~# '\<static\s\+' ? s:CONTEXT_IMPORT_STATIC : s:CONTEXT_IMPORT
                let b:dotexpr = substitute(statement, '^\s*import\s\+\(static\s\+\)\?', '', '')
            else
                let b:context_type = s:CONTEXT_PACKAGE_DECL
                let b:dotexpr = substitute(statement, '\s*package\s\+', '', '')
            endif

            " String literal
        elseif statement =~  '"\s*\.\s*$'
            let b:dotexpr = substitute(statement, '\s*\.\s*$', '\.', '')
            return start - strlen(b:incomplete)

        else
            " type declaration        NOTE: not supported generic yet.
            let idx_type = matchend(statement, '^\s*' . s:RE_TYPE_DECL)
            if idx_type != -1
                let b:dotexpr = strpart(statement, idx_type)
                " return if not after extends or implements
                if b:dotexpr !~ '^\(extends\|implements\)\s\+'
                    return -1
                endif
                let b:context_type = s:CONTEXT_NEED_TYPE
            endif

            let b:dotexpr = s:ExtractCleanExpr(statement)
        endif

        " all cases: " java.ut|" or " java.util.|" or "ja|"
        let b:incomplete = strpart(b:dotexpr, strridx(b:dotexpr, '.')+1)
        let b:dotexpr = strpart(b:dotexpr, 0, strridx(b:dotexpr, '.')+1)
        return start - strlen(b:incomplete)


        " method parameters, treat methodname or 'new' as an incomplete word
    elseif statement =~ '(\s*$'
        " TODO: Need to exclude method declaration?
        let b:context_type = s:CONTEXT_METHOD_PARAM
        let pos = strridx(statement, '(')
        let s:padding = strpart(statement, pos+1)
        let start = start - (len(statement) - pos)

        let statement = substitute(statement, '\s*(\s*$', '', '')

        " new ClassName?
        let str = matchstr(statement, '\<new\s\+' . s:RE_QUALID . '$')
        if str != ''
            let str = substitute(str, '^new\s\+', '', '')
            if !s:IsKeyword(str)
                let b:incomplete = '+'
                let b:dotexpr = str
                return start - len(b:dotexpr)
            endif

            " normal method invocations
        else
            let pos = match(statement, '\s*' . s:RE_IDENTIFIER . '$')
            " case: "method(|)", "this(|)", "super(|)"
            if pos == 0
                let statement = substitute(statement, '^\s*', '', '')
                " treat "this" or "super" as a type name.
                if statement == 'this' || statement == 'super' 
                    let b:dotexpr = statement
                    let b:incomplete = '+'
                    return start - len(b:dotexpr)

                elseif !s:IsKeyword(statement)
                    let b:incomplete = statement
                    return start - strlen(b:incomplete)
                endif

                " case: "expr.method(|)"
            elseif statement[pos-1] == '.' && !s:IsKeyword(strpart(statement, pos))
                let b:dotexpr = s:ExtractCleanExpr(strpart(statement, 0, pos))
                let b:incomplete = strpart(statement, pos)
                return start - strlen(b:incomplete)
            endif
        endif
    endif

    return -1
endf

func! s:EditExisting(fname, command)
    " Get the window number of the file in the current tab page.
    let winnr = bufwinnr(a:fname)
    if winnr <= 0
        " Not found, look in other tab pages.
        let bufnr = bufnr(a:fname)
        for i in range(tabpagenr('$'))
            if index(tabpagebuflist(i + 1), bufnr) >= 0
                " Make this tab page the current one and find the window number.
                exe 'tabnext ' . (i + 1)
                let winnr = bufwinnr(a:fname)
                break
            endif
        endfor
    endif

    if winnr > 0
        exe winnr . "wincmd w"
    elseif exists('*fnameescape')
        exe "tabedit " . fnameescape(a:fname)
    else
        exe "tabedit " . escape(a:fname, " \t\n*?[{`$\\%#'\"|!<")
    endif

    if a:command != ''
        call s:Trace("command: " . a:command)
        exe a:command
    endif

    redraw
endfunc

function! javacomplete#ReindexAllSources()
    call javacomplete#StartServer()
    call s:RunVimTool('-reindex', '', '')
    let s:cache = {}
endfunc

function! javacomplete#ReindexFile()
    let fname = expand("%:p")
    call s:RunVimTool('-reindex', '-file ' . fname, 's:SearchStaticImports in Batch')
endfunc

function! javacomplete#GoToDefinition()
    call javacomplete#StartServer()
    
    call s:FindStart()
    let b:incomplete = expand('<cword>')
    let unit = javacomplete#parse()
    if b:dotexpr != ''
        let ident = b:dotexpr[:-2]
        let other = b:incomplete
    else
        let ident = b:incomplete
        let other = ''
    endif
    if ident == "this"
        let ident = other
        let other = ""
    endif
    if ident != ''
        if stridx(ident, '.') >= 0 && other != ""
            let ci = s:DoGetClassInfo(ident . '.' . other)
            if get(ci, 'source', '') != ''
                call s:EditExisting(get(ci, 'source', ''), '')
            endif
        elseif (ident[0:0] ==# tolower(ident[0:0]) || ident ==# toupper(ident))
            let targetPos = java_parser#MakePos(line('.')-1, col('.')-1)
            let trees = s:SearchNameInAST(unit, ident, targetPos, 1)
            if other == '' " go to definition in this file
                if len(trees) > 0
                    let pp = java_parser#DecodePos(trees[0]['pos'])
                    call setpos('.', [0, pp.line + 1, pp.col, 0])
                endif
            else
                if len(trees) > 0
                    let type = trees[0].t
                    let ci = s:DoGetClassInfo(type)
                    if get(ci, 'source', '') != ''
                        if other != ''
                            for f in get(ci, 'fields', [])
                                if f.n ==# other
                                    call s:EditExisting(get(ci, 'source', ''), 'call setpos(".", [0, ' . f.pos[0]. ', ' . f.pos[1] . ', ' .  '0])')
                                    "call setpos(".", [0, f.pos[0], f.pos[1], 0])
                                endif
                            endfor
                            for f in get(ci, 'methods', [])
                                if f.n ==# other
                                    call s:EditExisting(get(ci, 'source', ''), 'call setpos(".", [0, ' . f.pos[0]. ', ' . f.pos[1] . ', ' .  '0])')
                                    "call setpos(".", [0, f.pos[0], f.pos[1], 0])
                                endif
                            endfor
                        else
                            call s:Trace(string(ci))
                        endif
                    endif
                endif
            endif
        else
        	let typeByName = s:SearchTypeByName(ident, unit)
            if len(typeByName) > 0
                let pos = java_parser#DecodePos(typeByName[0].pos)
                call setpos(".", [0, pos.line + 1, pos.col, 0])
            else
            let ci = s:DoGetClassInfo(ident)
            if get(ci, 'source', '') != ''
                call s:EditExisting(get(ci, 'source', ''), '')
                "exec "tabedit " . get(ci, 'source', '')
                if other != ''
                    for f in get(ci, 'fields', [])
                        if f.n ==# other
                            call s:EditExisting(get(ci, 'source', ''), 'call setpos(".", [0, ' . f.pos[0]. ', ' . f.pos[1] . ', ' .  '0])')
                        endif
                    endfor
                    for f in get(ci, 'methods', [])
                        if f.n ==# other
                            call s:EditExisting(get(ci, 'source', ''), 'call setpos(".", [0, ' . f.pos[0]. ', ' . f.pos[1] . ', ' .  '0])')
                        endif
                    endfor
                else
                endif
            endif
        endif
        endif
    else
    endif
    " klazz
endf

function! javacomplete#RestartWithFolder()
    call s:Trace("RestartWithFolder")
    call javacomplete#LoadConfig(1)
    call javacomplete#Restart()
endf

function! javacomplete#LoadConfig(reset)
  call s:Trace("LoadConfig")
  let l:local_conf = findfile('.java_complete', '.;')
  if l:local_conf != '' && filereadable(l:local_conf)
    let l:opts = readfile(l:local_conf)
    if a:reset
        call javacomplete#SetSourcePath("")
        call javacomplete#SetClassPath("")
    endif

    for l:opt in l:opts
      " Better handling of absolute path
      " I don't know if those pattern will work on windows
      " platform
      if matchstr(l:opt, '^c=') != ''
          call s:Trace("LoadConfig found class: " . substitute(l:opt, '^c=', '', 'g'))
          call javacomplete#AddClassPath(substitute(l:opt, '^c=', '', 'g'))
      elseif matchstr(l:opt, '^s=') != ''
          call s:Trace("LoadConfig found source: " . substitute(l:opt, '^s=', '', 'g'))
          call javacomplete#AddSourcePath(substitute(l:opt, '^s=', '', 'g'))
      endif
    endfor
  endif
endf

function! javacomplete#Restart()
    if !exists("g:nailgun_port")
        call s:Trace("Find nailgun port!!!!!!!!!")
        " find the first open nailgun_port, starting from the first one
        let l:found_nailgun_port = 0
        let l:tmp_try = g:first_nailgun_port
        while l:found_nailgun_port == 0
            call s:Trace("Try nailgun port: " . string(l:tmp_try))
            let l:unused = system("/usr/local/bin/nc -z 127.0.0.1 " . string(l:tmp_try))
            if v:shell_error " FFFOUND !!!
            	let l:found_nailgun_port = l:tmp_try
            endif
            let l:tmp_try = l:tmp_try + 1
        endwhile
        let g:nailgun_port = l:found_nailgun_port
    endif
    augroup javacomplete
        autocmd!
        " attach events
        autocmd! javacomplete VimLeave * call javacomplete#StopServer()
        " attach events
        autocmd! javacomplete BufWritePost *.java call javacomplete#ReindexFile()
    augroup END

    call s:System("ng --nailgun-port " . g:nailgun_port . " ng-stop", "Complete")
    let g:nailgun_started = 0
    call javacomplete#StartServer()
endf

function! javacomplete#StopServer()
    call s:System("ng --nailgun-port " . g:nailgun_port . " ng-stop", "Complete")
endf

function! javacomplete#StartServer()
    if g:nailgun_started == 0
        let classfile = globpath(&rtp, 'java/target/java_vim_sense-1.0-jar-with-dependencies.jar')
        call s:Trace("Starting classfile: " . classfile)
        call s:System("java -Xmx512m -cp " . classfile . " com.martiansoftware.nailgun.NGServer " . g:nailgun_port . " &", "Complete")
        let g:nailgun_started = 1
    endif
endf

" This function is used for the 'omnifunc' option. {{{1
function! javacomplete#Complete(findstart, base)
    if a:findstart
        return s:FindStart()
    endif

    call javacomplete#StartServer()
    " Return list of matches.
    call s:Trace('b:context_type: "' . b:context_type . '"  b:incomplete: "' . b:incomplete . '"  b:dotexpr: "' . b:dotexpr . '"')
    let l:tmp_incomplete = b:incomplete
    if b:dotexpr =~ '^\s*$' && b:incomplete =~ '^\s*$'
        return []
    endif

    let result = []
    if b:dotexpr !~ '^\s*$'
        if b:context_type == s:CONTEXT_AFTER_DOT
            let result = s:CompleteAfterDot(b:dotexpr)
        elseif b:context_type == s:CONTEXT_IMPORT || b:context_type == s:CONTEXT_IMPORT_STATIC || b:context_type == s:CONTEXT_PACKAGE_DECL || b:context_type == s:CONTEXT_NEED_TYPE
            let result = s:GetMembers(b:dotexpr[:-2])
        elseif b:context_type == s:CONTEXT_METHOD_PARAM
            if b:incomplete == '+'
                let result = s:GetConstructorList(b:dotexpr)
            else
                let result = s:CompleteAfterDot(b:dotexpr)
            endif
        endif

        " only incomplete word
    elseif b:incomplete !~ '^\s*$'
        " only need methods
        if b:context_type == s:CONTEXT_METHOD_PARAM
            let methods = s:SearchForName(b:incomplete, 0, 1)[1]
            call extend(result, eval('[' . s:DoGetMethodList(methods) . ']'))

        else
            let result = s:CompleteAfterWord(b:incomplete)
        endif

        " then no filter needed
        let b:incomplete = ''
    endif

    if len(result) > 0
        " filter according to b:incomplete
        if len(b:incomplete) > 0 && b:incomplete != '+'
            let result = filter(result, "type(v:val) == type('') ? v:val =~ '^" . b:incomplete . "' : v:val['word'] =~ '^" . b:incomplete . "'")
        endif

        if exists('s:padding') && !empty(s:padding)
            for item in result
                if type(item) == type("")
                    let item .= s:padding
                else
                    let item.word .= s:padding
                endif
            endfor
            unlet s:padding
        endif

        return result
    else
        call s:Trace("Got here, no completion")
        let res = s:RunVimTool('-n', '-class ' . l:tmp_incomplete, 'getclassnamepiece')
        if res =~ "^['"
        	call s:Trace("result: " . res)
            let result = eval(res)
            return result
        endif

    endif

    if exists("b:errormsg") && strlen(b:errormsg) > 0
        echoerr 'javacomplete error: ' . b:errormsg
        let b:errormsg = ''
    endif
endfunction

func! s:CheckAndAddImport(cls) "{{{2
    if match(a:cls,'\<\(char\|int\|void\|long\|double\|byte\|boolean\|float\)\>')==0
        return 0
    endif
    return s:AddImport(a:cls)
endf

func! javacomplete#ReplaceWithImport() "{{{2
        let l:line = line('.')
	let l:column = col('.')
        let l:str = getline(l:line)
	let l:head = strpart(l:str,0,match(l:str,'\([ \t,){(<]\|$\)',l:column))
        if l:head==''
            return
        endif
	"let l:target = strpart(matchstr(l:head,"[ \\t,(]\\(\\i\\+\\.\\)\\+\\i\\+$"),1)
	let l:target = strpart(matchstr(l:head,'[^0-9A-Za-z\.]\(\i\+\.\)\+\i\+$'),1)
        if l:target == ''
            return 
        endif
        let l:target_sub = strpart(l:target,match(l:target,"\\.\\i\\+$")+1)

        let l:line_pkg = search('^\s*package\s\+','nb')+1

        let l:line_imp = search('^\s*import\s\+'.l:target,'nb') +1
        if l:line_imp ==1
            exec '%s/'.l:target.'/'.l:target_sub.'/g'
            "call append(l:line_pkg,'import '.l:target.';')
			let idx = s:CheckAndAddImport(l:target)
            call cursor(l:line+idx,l:column-strlen(l:target)+strlen(l:target_sub))
        else
            exec l:line_imp.',$s/'.l:target.'/'.l:target_sub.'/g'
            call cursor(l:line,l:column-strlen(l:target)+strlen(l:target_sub))
        endif
endf

func! s:Vjde_get_pkg(cls) "{{{2
    return substitute(a:cls,'^\(\(\w\+\.\)*\)\(\w\+\)$','\1','')
endf
func! s:Vjde_get_cls(cls)
    return substitute(a:cls,'^\(\(\w\+\.\)*\)\(\w\+\)$','\3','')
endf

func! s:AddImport(cls) "{{{2
    if match(a:cls,'^java\.lang\.[A-Z]')==0
        return 0
    endif
    let l:line_imp = search('^\s*import\s\+'.a:cls.'\s*;','nb')
    if l:line_imp > 0 
            return 0
    endif
    let pkg = s:Vjde_get_pkg(a:cls)
    let l:line_imp = search('^\s*import\s\+'.pkg.'\*\s*;','nb')
    if l:line_imp > 0 
            return 0
    endif
    let l:line_imp = search('^\s*import\s\+','nb')
    if l:line_imp <= 0 
            let l:line_imp = search('^\s*package\s\+','nb')
    endif
    call append(l:line_imp,'import '.a:cls.';')
    return 1
endf

func! javacomplete#SortImports() range "{{{2
    let lines = []
    let index = a:firstline
    while index<= a:lastline
        call add(lines,getline(index))
        let index+=1
    endwhile
    call filter(lines,'strlen(v:val)>0')
    call sort(lines,'s:PackageNameCompare')
    let lstart = a:firstline
    let mcount = lstart
    let header =len(lines)>0? substitute(lines[0],'\s*import\s\+\(static\s\+\)*\(\w\+\).*$','\2',''):''
    for lstr in lines
        let mh = substitute(lstr,'\s*import\s\+\(static\s\+\)*\(\w\+\).*$','\2','')
        if mh != header
            let header = mh
            if mcount <= a:lastline
                call setline(mcount,'')
            else
                call append(mcount-1,'')
            endif
            let mcount+=1
        endif
        if mcount <= a:lastline
            call setline(mcount,lstr)
        else
            call append(mcount-1,lstr)
        endif
        let mcount+=1
    endfor
    return
endf

func! s:PackageNameCompare1(i1,i2)
    return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endf

func! s:PackageNameCompare(i1,i2) "{{{2
    let maw = substitute(a:i1, '\s*import\s\+\(static\s\+\)*\(\w\+\)\..*$', '\2', '')
    let mbw = substitute(a:i2, '\s*import\s\+\(static\s\+\)*\(\w\+\)\..*$', '\2', '')
    if maw == mbw
        return s:PackageNameCompare1(a:i1, a:i2)
    endif
    if 0
    elseif maw == 'com'
        return -1
    elseif mbw == 'com'
        return 1
    elseif maw == 'java'
        return 1
    elseif mbw == 'java'
        return -1
    elseif maw == 'javax'
        return 1
    elseif mbw == 'javax'
        return -1
    elseif maw == 'org'
        return -1
    elseif mbw == 'org'
        return 1
    elseif maw == 'net'
        return -1
    elseif mbw == 'net'
        return 1
    else
        return s:PackageNameCompare1(a:i1,a:i2)
    endif
endf

" Precondition:    incomplete must be a word without '.'.
" return all the matched, variables, fields, methods, types, packages
fu! s:CompleteAfterWord(incomplete)
    " packages in jar files
    if !exists('s:all_packages_in_jars_loaded')
        call s:DoGetPackageInfoByReflection('-', '-P')
        let s:all_packages_in_jars_loaded = 1
    endif

    let pkgs = []
    let types = []
    for key in keys(s:cache)
        if key =~# '^' . a:incomplete
            if type(s:cache[key]) == type('') || get(s:cache[key], 'tag', '') == 'PACKAGE'
                call add(pkgs, {'kind': 'P', 'word': key})

                " filter out type info
            elseif b:context_type != s:CONTEXT_PACKAGE_DECL && b:context_type != s:CONTEXT_IMPORT && b:context_type != s:CONTEXT_IMPORT_STATIC
                call add(types, {'kind': 'C', 'word': key})
            endif
        endif
    endfor

    "let pkgs += s:DoGetPackageInfoInDirs(a:incomplete, b:context_type == s:CONTEXT_PACKAGE_DECL, 1)

    " add accessible types which name beginning with the incomplete in source files
    " TODO: remove the inaccessible
    if b:context_type != s:CONTEXT_PACKAGE_DECL
        " single type import
        for fqn in s:GetImports('imports_fqn')
            let name = fqn[strridx(fqn, ".")+1:]
            if name =~ '^' . a:incomplete
                call add(types, {'kind': 'C', 'word': name, 'fqn': fqn})
            endif
        endfor
        for fqn in s:GetImports('imports_star')
            let fqn = fqn[0:strridx(fqn, ".")-1]
            call s:DoGetTypeInfoForFQN([fqn], "")
            let ti = s:GetMembers(fqn)    " s:DoGetPackegInfo(ident)
            if len(ti) > 0
                for cn in ti
                    let name = cn['word']
                    if name =~ '^' . a:incomplete
                        call add(types, cn)
                    endif
                endfor
            endif
        endfor

        let packageName = s:GetPackageName()
        let dp = get(s:cache, packageName, {})
        if dp != {}
            for shortClassName in get(dp, 'classes', {})
                let fullClassName = packageName . "." . shortClassName
                let name = fullClassName[strridx(fullClassName, ".")+1:]
                if name =~ '^' . a:incomplete
                    call add(types, {'kind': 'C', 'word': name, 'fqn': fullClassName})
                endif
            endfor
        endif

        " current file
        let lnum_old = line('.')
        let col_old = col('.')
        call cursor(1, 1)
        while 1
            let lnum = search('\<\C\(class\|interface\|enum\)[ \t\n\r]\+' . a:incomplete . '[a-zA-Z0-9_$]*[< \t\n\r]', 'W')
            if lnum == 0
                break
            elseif s:InCommentOrLiteral(line('.'), col('.'))
                continue
            else
                normal w
                call add(types, {'kind': 'C', 'word': matchstr(getline(line('.'))[col('.')-1:], s:RE_IDENTIFIER)})
            endif
        endwhile
        call cursor(lnum_old, col_old)

    endif


    let result = []

    " add variables and members in source files
    if b:context_type == s:CONTEXT_AFTER_DOT
        let matches = s:SearchForName(a:incomplete, 0, 0)
        let result += sort(eval('[' . s:DoGetFieldList(matches[2]) . ']'))
        let result += sort(eval('[' . s:DoGetMethodList(matches[1]) . ']'))
    endif
    let result += sort(pkgs)
    let result += sort(types)

    return result
endfu


" Precondition:    expr must end with '.'
" return members of the value of expression
function! s:CompleteAfterDot(expr)
    let items = s:ParseExpr(a:expr)        " TODO: return a dict containing more than items
    if empty(items)
        return []
    endif

    " 0. String literal
    call s:Info('P0. "str".|')
    if items[-1] =~  '"$'
        return s:GetMemberList("java.lang.String")
    endif


    let ti = {}
    let ii = 1        " item index
    let itemkind = 0

    "
    " optimized process
    "
    " search the longest expr consisting of ident
    let i = 1
    let k = i
    while i < len(items) && items[i] =~ '^\s*' . s:RE_IDENTIFIER . '\s*$'
        let ident = substitute(items[i], '\s', '', 'g')
        if ident == 'class' || ident == 'this' || ident == 'super'
            let k = i
            " return when found other keywords
        elseif s:IsKeyword(ident)
            return []
        endif
        let items[i] = substitute(items[i], '\s', '', 'g')
        let i += 1
    endwhile


    if i > 1
        " cases: "this.|", "super.|", "ClassName.this.|", "ClassName.super.|", "TypeName.class.|"
        if items[k] ==# 'class' || items[k] ==# 'this' || items[k] ==# 'super'
            call s:Info('O1. ' . items[k] . ' ' . join(items[:k-1], '.'))
            let ti = s:DoGetClassInfo(items[k] == 'class' ? 'java.lang.Class' : join(items[:k-1], '.'))
            if !empty(ti)
                let itemkind = items[k] ==# 'this' ? 1 : items[k] ==# 'super' ? 2 : 0
                let ii = k+1
            else
                return []
            endif

            " case: "java.io.File.|"
        else
            let fqn = join(items[:i-1], '.')
            let srcpath = join(s:GetSourceDirs(expand('%:p'), s:GetPackageName()), ',')
            call s:Info('O2. ' . fqn)
            call s:DoGetTypeInfoForFQN([fqn], srcpath)
            if get(get(s:cache, fqn, {}), 'tag', '') == 'CLASSDEF'
                let ti = s:cache[fqn]
                let itemkind = 11
                let ii = i
            endif
        endif
    endif


    "
    " first item
    "
    if empty(ti)
        " cases:
        " 1) "int.|", "void.|"    - primitive type or pseudo-type, return `class`
        " 2) "this.|", "super.|"    - special reference
        " 3) "var.|"        - variable or field
        " 4) "String.|"         - type imported or defined locally
        " 5) "java.|"           - package
        if items[0] =~ '^\s*' . s:RE_IDENTIFIER . '\s*$'
            let ident = substitute(items[0], '\s', '', 'g')

            if s:IsKeyword(ident)
                " 1)
                call s:Info('F1. "' . ident . '.|"')
                if ident ==# 'void' || s:IsBuiltinType(ident)
                    let ti = s:PRIMITIVE_TYPE_INFO
                    let itemkind = 11

                    " 2)
                    call s:Info('F2. "' . ident . '.|"')
                elseif ident ==# 'this' || ident ==# 'super'
                    let itemkind = ident ==# 'this' ? 1 : ident ==# 'super' ? 2 : 0
                    let ti = s:DoGetClassInfo(ident)
                endif

            else
                " 3)
                let typename = s:GetDeclaredClassName(ident)
                call s:Info('F3. "' . ident . '.|"  typename: "' . typename . '"')
                if (typename != '')
                    if typename[0] == '[' || typename[-1:] == ']'
                        let ti = s:ARRAY_TYPE_INFO
                    elseif typename != 'void' && !s:IsBuiltinType(typename)
                        let ti = s:DoGetClassInfo(typename)
                    endif

                else
                    " 4)
                    call s:Info('F4. "TypeName.|"')
                    let ti = s:DoGetClassInfo(ident)
                    let itemkind = 11

                    if get(ti, 'tag', '') != 'CLASSDEF'
                        let ti = {}
                    endif

                    " 5)
                    if empty(ti)
                        call s:Info('F5. "package.|"')
                        unlet ti
                        let ti = s:GetMembers(ident)    " s:DoGetPackegInfo(ident)
                        let itemkind = 20
                    endif
                endif
            endif

            " method invocation:    "method().|"    - "this.method().|"
        elseif items[0] =~ '^\s*' . s:RE_IDENTIFIER . '\s*('
            let ti = s:MethodInvocation(items[0], ti, itemkind)

            " array type, return `class`: "int[] [].|", "java.lang.String[].|", "NestedClass[].|"
        elseif items[0] =~# s:RE_ARRAY_TYPE
            call s:Info('array type. "' . items[0] . '"')
            let qid = substitute(items[0], s:RE_ARRAY_TYPE, '\1', '')
            if s:IsBuiltinType(qid) || (!s:HasKeyword(qid) && !empty(s:DoGetClassInfo(qid)))
                let ti = s:PRIMITIVE_TYPE_INFO
                let itemkind = 11
            endif

            " class instance creation expr:    "new String().|", "new NonLoadableClass().|"
            " array creation expr:    "new int[i=1] [val()].|", "new java.lang.String[].|"
        elseif items[0] =~ '^\s*new\s\+'
            call s:Info('creation expr. "' . items[0] . '"')
            let subs = split(substitute(items[0], '^\s*new\s\+\(' .s:RE_QUALID. '\)\s*\([([]\)', '\1;\2', ''), ';')
            if subs[1][0] == '['
                let ti = s:ARRAY_TYPE_INFO
            elseif subs[1][0] == '('
                let ti = s:DoGetClassInfo(subs[0])
                " exclude interfaces and abstract class.  TODO: exclude the inaccessible
                if get(ti, 'flags', '')[-10:-10] || get(ti, 'flags', '')[-11:-11]
                    echo 'cannot instantiate the type ' . subs[0]
                    let ti = {}
                    return []
                endif
            endif

            " casting conversion:    "(Object)o.|"
        elseif items[0] =~ s:RE_CASTING
            call s:Info('Casting conversion. "' . items[0] . '"')
            let subs = split(substitute(items[0], s:RE_CASTING, '\1;\2', ''), ';')
            let ti = s:DoGetClassInfo(subs[0])

            " array access:    "var[i][j].|"        Note: "var[i][]" is incorrect
        elseif items[0] =~# s:RE_ARRAY_ACCESS
            let subs = split(substitute(items[0], s:RE_ARRAY_ACCESS, '\1;\2', ''), ';')
            if get(subs, 1, '') !~ s:RE_BRACKETS
                let typename = s:GetDeclaredClassName(subs[0])
                call s:Info('ArrayAccess. "' .items[0]. '.|"  typename: "' . typename . '"')
                if (typename != '')
                    let ti = s:ArrayAccess(typename, items[0])
                endif
            endif
        endif
    endif


    "
    " next items
    "
    while !empty(ti) && ii < len(items)
        " method invocation:    "PrimaryExpr.method(parameters)[].|"
        if items[ii] =~ '^\s*' . s:RE_IDENTIFIER . '\s*('
            let ti = s:MethodInvocation(items[ii], ti, itemkind)
            let itemkind = 0
            let ii += 1
            continue


            " expression of selection, field access, array access
        elseif items[ii] =~ s:RE_SELECT_OR_ACCESS
            let subs = split(substitute(items[ii], s:RE_SELECT_OR_ACCESS, '\1;\2', ''), ';')
            let ident = subs[0]
            let brackets = get(subs, 1, '')

            " package members
            if itemkind/10 == 2 && empty(brackets) && !s:IsKeyword(ident)
                let qn = join(items[:ii], '.')
                if type(ti) == type([])
                    let idx = s:Index(ti, ident, 'word')
                    if idx >= 0
                        if ti[idx].kind == 'P'
                            unlet ti
                            let ti = s:GetMembers(qn)
                            let ii += 1
                            continue
                        elseif ti[idx].kind == 'C'
                            unlet ti
                            let ti = s:DoGetClassInfo(qn)
                            let itemkind = 11
                            let ii += 1
                            continue
                        endif
                    endif
                endif


                " type members
            elseif itemkind/10 == 1 && empty(brackets)
                if ident ==# 'class' || ident ==# 'this' || ident ==# 'super'
                    let ti = s:DoGetClassInfo(ident == 'class' ? 'java.lang.Class' : join(items[:ii-1], '.'))
                    let itemkind = ident ==# 'this' ? 1 : ident ==# 'super' ? 2 : 0
                    let ii += 1
                    continue

                elseif !s:IsKeyword(ident) && type(ti) == type({}) && get(ti, 'tag', '') == 'CLASSDEF'
                    " accessible static field
                    "let idx = s:Index(get(ti, 'fields', []), ident, 'n')
                    "if idx >= 0 && s:IsStatic(ti.fields[idx].m)
                    "  let ti = s:ArrayAccess(ti.fields[idx].t, items[ii])
                    let members = s:SearchMember(ti, ident, 1, itemkind, 1, 0)
                    if !empty(members[2])
                        let ti = s:ArrayAccess(members[2][0].t, items[ii])
                        let itemkind = 0
                        let ii += 1
                        continue
                    endif

                    " accessible nested type
                    "if !empty(filter(copy(get(ti, 'classes', [])), 'strpart(v:val, strridx(v:val, ".")) ==# "' . ident . '"'))
                    if !empty(members[0])
                        let ti = s:DoGetClassInfo(join(items[:ii], '.'))
                        let ii += 1
                        continue
                    endif
                endif


                " instance members
            elseif itemkind/10 == 0 && !s:IsKeyword(ident)
                if type(ti) == type({}) && get(ti, 'tag', '') == 'CLASSDEF'
                    "let idx = s:Index(get(ti, 'fields', []), ident, 'n')
                    "if idx >= 0
                    "  let ti = s:ArrayAccess(ti.fields[idx].t, items[ii])
                    let members = s:SearchMember(ti, ident, 1, itemkind, 1, 0)
                    let itemkind = 0
                    if !empty(members[2])
                        let ti = s:ArrayAccess(members[2][0].t, items[ii])
                        let ii += 1
                        continue
                    endif
                endif
            endif
        endif

        return []
    endwhile


    " type info or package info --> members
    if !empty(ti)
        if type(ti) == type({})
            if get(ti, 'tag', '') == 'CLASSDEF'
                if get(ti, 'name', '') == '!'
                    return [{'kind': 'f', 'word': 'class', 'menu': 'Class'}]
                elseif get(ti, 'name', '') == '['
                    return s:ARRAY_TYPE_MEMBERS
                elseif itemkind < 20
                    return s:DoGetMemberList(ti, itemkind)
                endif
            elseif get(ti, 'tag', '') == 'PACKAGE'
                " TODO: ti -> members, in addition to packages in dirs
                return s:GetMembers( substitute(join(items, '.'), '\s', '', 'g') )
            endif
        elseif type(ti) == type([])
            return ti
        endif
    endif

    return []
endfunction


fu! s:MethodInvocation(expr, ti, itemkind)
    let subs = split(substitute(a:expr, '\s*\(' . s:RE_IDENTIFIER . '\)\s*\((.*\)', '\1;\2', ''), ';')

    " all methods matched
    if empty(a:ti)
        let methods = s:SearchForName(subs[0], 0, 1)[1]
    elseif type(a:ti) == type({}) && get(a:ti, 'tag', '') == 'CLASSDEF'
        let methods = s:SearchMember(a:ti, subs[0], 1, a:itemkind, 1, 0, a:itemkind == 2)[1]
        "    let methods = s:filter(get(a:ti, 'methods', []), 'item.n == "' . subs[0] . '"')
        "    if a:itemkind == 1 || a:itemkind == 2
        "      let methods += s:filter(get(a:ti, 'declared_methods', []), 'item.n == "' . subs[0] . '"')
        "    endif
    else
        let methods = []
    endif

    let method = s:DetermineMethod(methods, subs[1])
    if !empty(method)
        return s:ArrayAccess(method.r, a:expr)
    endif
    return {}
endfu

fu! s:ArrayAccess(arraytype, expr)
    if a:expr =~ s:RE_BRACKETS    | return {} | endif
    let typename = a:arraytype

    let dims = 0
    if typename[0] == '[' || typename[-1:] == ']' || a:expr[-1:] == ']'
        let dims = s:CountDims(a:expr) - s:CountDims(typename)
        if dims == 0
            let typename = matchstr(typename, s:RE_IDENTIFIER)
        elseif dims < 0
            return s:ARRAY_TYPE_INFO
        else
            "echoerr 'dims exceeds'
        endif
    endif
    if dims == 0
        if typename != 'void' && !s:IsBuiltinType(typename)
            return s:DoGetClassInfo(typename)
        endif
    endif
    return {}
endfu


" Quick information                        {{{1
function! MyBalloonExpr()
    if (searchdecl(v:beval_text, 1, 0) == 0)
        return s:GetVariableDeclaration()
    endif
    return ''
    "  return 'Cursor is at line ' . v:beval_lnum .
    "    \', column ' . v:beval_col .
    "    \ ' of file ' .  bufname(v:beval_bufnr) .
    "    \ ' on word "' . v:beval_text . '"'
endfunction
"set bexpr=MyBalloonExpr()
"set ballooneval

" parameters information                    {{{1
fu! javacomplete#CompleteParamsInfo(findstart, base)
    if a:findstart
        return col('.') - 1
    endif

    let mi = s:GetMethodInvocationExpr(s:GetStatement())
    if empty(mi.method)
        return []
    endif

    " TODO: how to determine overloaded functions
    "let mi.params = s:EvalParams(mi.params)
    if empty(mi.expr)
        let methods = s:SearchForName(mi.method, 0, 1)[1]
        let result = eval('[' . s:DoGetMethodList(methods) . ']')
    elseif mi.method == '+'
        let result = s:GetConstructorList(mi.expr)
    else
        let result = s:CompleteAfterDot(mi.expr)
    endif

    if !empty(result)
        if !empty(mi.method) && mi.method != '+'
            let result = filter(result, "type(v:val) == type('') ? v:val ==# '" . mi.method . "' : v:val['word'] ==# '" . mi.method . "('")
        endif
        return result

    endif
endfu

" scanning and parsing                            {{{1

" Search back from the cursor position till meeting '{' or ';'.
" '{' means statement start, ';' means end of a previous statement.
" Return: statement before cursor
" Note: It's the base for parsing. And It's OK for most cases.
function! s:GetStatement()
    if getline('.') =~ '^\s*\(import\|package\)\s\+'
        return strpart(getline('.'), match(getline('.'), '\(import\|package\)'), col('.')-1)
    endif

    let lnum_old = line('.')
    let col_old = col('.')

    while 1
        if search('[{};]\|<%\|<%!', 'bW') == 0
            let lnum = 1
            let col  = 1
        else
            if s:InCommentOrLiteral(line('.'), col('.'))
                continue
            endif

            normal w
            let lnum = line('.')
            let col = col('.')
        endif
        break
    endwhile

    silent call cursor(lnum_old, col_old)
    return s:MergeLines(lnum, col, lnum_old, col_old)
endfunction

fu! s:MergeLines(lnum, col, lnum_old, col_old)
    let lnum = a:lnum
    let col = a:col

    let str = ''
    if lnum < a:lnum_old
        let str = s:Prune(strpart(getline(lnum), a:col-1))
        let lnum += 1
        while lnum < a:lnum_old
            let str  .= s:Prune(getline(lnum))
            let lnum += 1
        endwhile
        let col = 1
    endif
    let lastline = strpart(getline(a:lnum_old), col-1, a:col_old-col)
    let str .= s:Prune(lastline, col)
    let str = s:RemoveBlockComments(str)
    " generic in JAVA 5+
    while match(str, s:RE_TYPE_ARGUMENTS) != -1
        let str = substitute(str, '\(' . s:RE_TYPE_ARGUMENTS . '\)', '\=repeat(" ", len(submatch(1)))', 'g')
    endwhile
    let str = substitute(str, '\s\s\+', ' ', 'g')
    let str = substitute(str, '\([.()]\)[ \t]\+', '\1', 'g')
    let str = substitute(str, '[ \t]\+\([.()]\)', '\1', 'g')
    return s:Trim(str) . matchstr(lastline, '\s*$')
endfu

" Extract a clean expr, removing some non-necessary characters. 
fu! s:ExtractCleanExpr(expr)
    let cmd = substitute(a:expr, '[ \t\r\n]\+\([.()[\]]\)', '\1', 'g')
    let cmd = substitute(cmd, '\([.()[\]]\)[ \t\r\n]\+', '\1', 'g')

    let pos = strlen(cmd)-1 
    while pos >= 0 && cmd[pos] =~ '[a-zA-Z0-9_.)\]]'
        if cmd[pos] == ')'
            let pos = s:SearchPairBackward(cmd, pos, '(', ')')
        elseif cmd[pos] == ']'
            let pos = s:SearchPairBackward(cmd, pos, '[', ']')
        endif
        let pos -= 1
    endwhile

    " try looking back for "new"
    let idx = match(strpart(cmd, 0, pos+1), '\<new[ \t\r\n]*$')

    return strpart(cmd, idx != -1 ? idx : pos+1)
endfu

fu! s:ParseExpr(expr)
    let items = []
    let s = 0
    " recognize ClassInstanceCreationExpr as a whole
    let e = matchend(a:expr, '^\s*new\s\+' . s:RE_QUALID . '\s*[([]')-1
    if e < 0
        let e = match(a:expr, '[.([]')
    endif
    let isparen = 0
    while e >= 0
        if a:expr[e] == '.'
            let subexpr = strpart(a:expr, s, e-s)
            call extend(items, isparen ? s:ProcessParentheses(subexpr) : [subexpr])
            let isparen = 0
            let s = e + 1
        elseif a:expr[e] == '('
            let e = s:GetMatchedIndexEx(a:expr, e, '(', ')')
            let isparen = 1
            if e < 0
                break
            else
                let e = matchend(a:expr, '^\s*[.[]', e+1)-1
                continue
            endif
        elseif a:expr[e] == '['
            let e = s:GetMatchedIndexEx(a:expr, e, '[', ']')
            if e < 0
                break
            else
                let e = matchend(a:expr, '^\s*[.[]', e+1)-1
                continue
            endif
        endif
        let e = match(a:expr, '[.([]', s)
    endwhile
    let tail = strpart(a:expr, s)
    if tail !~ '^\s*$'
        call extend(items, isparen ? s:ProcessParentheses(tail) : [tail])
    endif

    return items
endfu

" Given optional argument, call s:ParseExpr() to parser the nonparentheses expr
fu! s:ProcessParentheses(expr, ...)
    let s = matchend(a:expr, '^\s*(')
    if s != -1
        let e = s:GetMatchedIndexEx(a:expr, s-1, '(', ')')
        if e >= 0
            let tail = strpart(a:expr, e+1)
            if tail =~ '^\s*[\=$'
                return s:ProcessParentheses(strpart(a:expr, s, e-s), 1)
            elseif tail =~ '^\s*\w'
                return [strpart(a:expr, 0, e+1) . 'obj.']
            endif
        endif

        " multi-dot-expr except for new expr
    elseif a:0 > 0 && stridx(a:expr, '.') != match(a:expr, '\.\s*$') && a:expr !~ '^\s*new\s\+'
        return s:ParseExpr(a:expr)
    endif
    return [a:expr]
endfu

" return {'expr': , 'method': , 'params': }
fu! s:GetMethodInvocationExpr(expr)
    let idx = strlen(a:expr)-1 
    while idx >= 0
        if a:expr[idx] == '('
            break
        elseif a:expr[idx] == ')'
            let idx = s:SearchPairBackward(a:expr, idx, '(', ')')
        elseif a:expr[idx] == ']'
            let idx = s:SearchPairBackward(a:expr, idx, '[', ']')
        endif
        let idx -= 1
    endwhile

    let mi = {'expr': strpart(a:expr, 0, idx+1), 'method': '', 'params': strpart(a:expr, idx+1)}
    let idx = match(mi.expr, '\<new\s\+' . s:RE_QUALID . '\s*(\s*$')
    if idx >= 0
        let mi.method = '+'
        let mi.expr = substitute(matchstr(strpart(mi.expr, idx+4), s:RE_QUALID), '\s', '', 'g')
    else
        let idx = match(mi.expr, '\<' . s:RE_IDENTIFIER . '\s*(\s*$')
        if idx >= 0
            let subs = s:SplitAt(mi.expr, idx-1)
            let mi.method = substitute(subs[1], '\s*(\s*$', '', '')
            let mi.expr = s:ExtractCleanExpr(subs[0])
        endif
    endif
    return mi
endfu

" Generate Imports                            {{{1
function! s:ParseImportsDeclarations()
    let imports = []

    let lnum_old = line('.')
    let col_old = col('.')
    let window_position = winsaveview()
    call cursor(1, 1)

    if &ft == 'jsp'
        while 1
            let lnum = search('\<import\s*=[''"]', 'W')
            if (lnum == 0)
                break
            endif

            let str = getline(lnum)
            if str =~ '<%\s*@\s*page\>' || str =~ '<jsp:\s*directive.page\>'
                let str = substitute(str, '.*import=[''"]\([a-zA-Z0-9_$.*, \t]\+\)[''"].*', '\1', '')
                for item in split(str, ',')
                    call add(imports, substitute(item, '\s', '', 'g'))
                endfor
            endif
        endwhile
    else
    while 1
        let lnum = search('\<import\>', 'W')
        if (lnum == 0)
            break
        elseif !s:InComment(line("."), col(".")-1)
            normal w
            " TODO: search semicolon or import keyword, excluding comment
            let stat = matchstr(getline(lnum)[col('.')-1:], '\(static\s\+\)\?\(' .s:RE_QUALID. '\%(\s*\.\s*\*\)\?\)\s*;')
            if !empty(stat)
                call add(imports, stat[:-2])
            endif
        endif
    endwhile
    endif

    call cursor(lnum_old, col_old)
    call winrestview(window_position)
    return imports
endfunction

function! s:UpdateImportsCache(filekey)
    
    let props = get(s:files, a:filekey, {})

    let props['imports'] = a:filekey == s:GetCurrentFileKey() ? s:ParseImportsDeclarations() : props.unit.imports
    let props['imports_static']    = []
    let props['imports_fqn'] = []
    let props['imports_star'] = ['java.lang.']
    if &ft == 'jsp' || a:filekey =~ '\.jsp$'
        let props.imports_star += ['javax.servlet.', 'javax.servlet.http.', 'javax.servlet.jsp.']
    endif

    for import in props.imports
        let subs = split(substitute(import, '^\s*\(static\s\+\)\?\(' .s:RE_QUALID. '\%(\s*\.\s*\*\)\?\)\s*$', '\1;\2', ''), ';', 1)
        let qid = substitute(subs[1] , '\s', '', 'g')
        if !empty(subs[0])
            call add(props.imports_static, qid)
        elseif qid[-1:] == '*'
            call add(props.imports_star, qid[:-2])
        else
            call add(props.imports_fqn, qid)
        endif
    endfor
    let s:files[a:filekey] = props
endfunction

fu! s:GetImports(kind, ...)
    let filekey = a:0 > 0 && !empty(a:1) ? a:1 : s:GetCurrentFileKey()
    let props = get(s:files, filekey, {})

    if !has_key(props, a:kind)
        call s:UpdateImportsCache(filekey)
        let props = s:files[filekey]
    endif
    return get(props, a:kind, [])
endfu

" search for name in 
" return the fqn matched
fu! s:SearchSingleTypeImport(name, fqns)
    let matches = s:filter(a:fqns, 'item =~# ''\<' . a:name . '$''')
    if len(matches) == 1
        return matches[0]
    elseif !empty(matches)
        echoerr 'Name "' . a:name . '" conflicts between ' . join(matches, ' and ')
        return matches[0]
    endif
    return ''
endfu

" search for name in static imports, return list of members with the same name
" return [types, methods, fields]
fu! s:SearchStaticImports(name, fullmatch)
    let result = [[], [], []]
    let candidates = []        " list of the canonical name
    for item in s:GetImports('imports_static')
        if item[-1:] == '*'        " static import on demand
            call add(candidates, item[:-3])
        elseif item[strridx(item, '.')+1:] ==# a:name
                    \ || (!a:fullmatch && item[strridx(item, '.')+1:] =~ '^' . a:name)
            call add(candidates, item[:strridx(item, '.') - 1]) " TODOADR: check correct
        endif
    endfor
    if empty(candidates)
        return result
    endif


    " read type info which are not in cache
    let commalist = ''
    for typename in candidates
        if !has_key(s:cache, typename)
            let commalist .= typename . ','
        endif
    endfor
    if commalist != ''
        let res = s:RunVimTool('-E', '-class ' . commalist, 's:SearchStaticImports in Batch')
        if res =~ "^{'"
            let dict = eval(res)
            for key in keys(dict)
                let s:cache[key] = s:Sort(dict[key])
            endfor
        endif
    endif

    " search in all candidates
    for typename in candidates
        let ti = get(s:cache, typename, 0)
        if type(ti) == type({}) && get(ti, 'tag', '') == 'CLASSDEF'
            let members = s:SearchMember(ti, a:name, a:fullmatch, 12, 1, 0)
            let result[1] += members[1]
            let result[2] += members[2]
        else
            " TODO: mark the wrong import declaration.
        endif
    endfor
    return result
endfu

" search decl                            {{{1
" Return: The declaration of identifier under the cursor
" Note: The type of a variable must be imported or a fqn.
function! s:GetVariableDeclaration()
    let lnum_old = line('.')
    let col_old = col('.')

    silent call search('[^a-zA-Z0-9$_.,?<>[\] \t\r\n]', 'bW')    " call search('[{};(,]', 'b')
    normal w
    let lnum = line('.')
    let col = col('.')
    if (lnum == lnum_old && col == col_old)
        return ''
    endif

    silent call cursor(lnum_old, col_old)
    return s:MergeLines(lnum, col, lnum_old, col_old)
endfunction

function! s:FoundClassDeclaration(type)
    let lnum_old = line('.')
    let col_old = col('.')
    call cursor(1, 1)
    while 1
        let lnum = search('\<\C\(class\|interface\|enum\)[ \t\n\r]\+' . a:type . '[< \t\n\r]', 'W')
        if lnum == 0 || !s:InCommentOrLiteral(line('.'), col('.'))
            break
        endif
    endwhile

    " search mainly for the cases: " class /* block comment */ Ident"
    "                 " class // comment \n Ident "
    if lnum == 0
        let found = 0
        while !found
            let lnum = search('\<\C\(class\|interface\|enum\)[ \t\n\r]\+', 'W')
            if lnum == 0
                break
            elseif s:InCommentOrLiteral(line('.'), col('.'))
                continue
            else
                normal w
                " skip empty line
                while getline(line('.'))[col('.')-1] == ''
                    normal w
                endwhile
                let lnum = line('.')
                let col = col('.')
                while 1
                    if match(getline(lnum)[col-1:], '^[ \t\n\r]*' . a:type . '[< \t\n\r]') >= 0
                        let found = 1
                        " meets comment
                    elseif match(getline(lnum)[col-1:], '^[ \t\n\r]*\(//\|/\*\)') >= 0
                        if getline(lnum)[col-1:col] == '//'
                            normal $eb
                        else
                            let lnum = search('\*\/', 'W')
                            if lnum == 0
                                break
                            endif
                            normal web
                        endif
                        let lnum = line('.')
                        let col = col('.')
                        continue
                    endif
                    break
                endwhile
            endif
        endwhile
    endif

    silent call cursor(lnum_old, col_old)
    return lnum
endfu

" regexp samples:
" echo search('\(\(public\|protected|private\)[ \t\n\r]\+\)\?\(\(static\)[ \t\n\r]\+\)\?\(\<class\>\|\<interface\>\)[ \t\n\r]\+HelloWorld[^a-zA-Z0-9_$]', 'W')
" echo substitute(getline('.'), '.*\(\(public\|protected\|private\)[ \t\n\r]\+\)\?\(\(static\)[ \t\n\r]\+\)\?\(\<class\>\|\<interface\>\)\s\+\([a-zA-Z0-9_]\+\)\s\+\(\(implements\|extends\)\s\+\([^{]\+\)\)\?\s*{.*', '["\1", "\2", "\3", "\4", "\5", "\6", "\8", "\9"]', '')
" code sample: 
function! s:GetClassDeclarationOf(type)
    call cursor(1, 1)
    let decl = []

    let lnum = search('\(\<class\>\|\<interface\>\)[ \t\n\r]\+' . a:type . '[^a-zA-Z0-9_$]', 'W')
    if (lnum != 0)
        " TODO: search back for optional 'public | private' and 'static'
        " join lines till to '{'
        let lnum_end = search('{')
        if (lnum_end != 0)
            let str = ''
            while (lnum <= lnum_end)
                let str = str . getline(lnum)
                let lnum = lnum + 1
            endwhile

            exe "let decl = " . substitute(str, '.*\(\<class\>\|\<interface\>\)\s\+\([a-zA-Z0-9_]\+\)\s\+\(\(implements\|extends\)\s\+\([^{]\+\)\)\?\s*{.*', '["\1", "\2", "\4", "\5"]', '')
        endif
    endif

    return decl
endfunction

" return list
"    0    class | interface
"    1    name
"   [2    implements | extends ]
"   [3    parent list ]
function! s:GetThisClassDeclaration()
    let lnum_old = line('.')
    let col_old = col('.')

    while (1)
        call search('\(\<class\C\>\|\<interface\C\>\|\<enum\C\>\)[ \t\r\n]\+', 'bW')
        if !s:InComment(line("."), col(".")-1)
            if getline('.')[col('.')-2] !~ '\S'
                break
            endif
        end
    endwhile

    " join lines till to '{'
    let str = ''
    let lnum = line('.')
    call search('{')
    let lnum_end = line('.')
    while (lnum <= lnum_end)
        let str = str . getline(lnum)
        let lnum = lnum + 1
    endwhile

    let declaration = substitute(str, '.*\(\<class\>\|\<interface\>\)\s\+\([a-zA-Z0-9_]\+\)\(\s\+\(implements\|extends\)\s\+\([^{]\+\)\)\?\s*{.*', '["\1", "\2", "\4", "\5"]', '')
    call cursor(lnum_old, col_old)
    if declaration !~ '^['
        echoerr 'Some error occurs when recognizing this class:' . declaration
        return ['', '']
    endif
    exe "let list = " . declaration
    return list
endfunction

" searches for name of a var or a field and determines the meaning  {{{1

" The standard search order of a variable or field is as follows:
" 1. Local variables declared in the code block, for loop, or catch clause
"    from current scope up to the most outer block, a method or an initialization block
" 2. Parameters if the code is in a method or ctor
" 3. Fields of the type
" 4. Accessible inherited fields.
" 5. If the type is a nested type,
"    local variables of the enclosing block or fields of the enclosing class.
"    Note that if the type is a static nested type, only static members of an enclosing block or class are searched
"    Reapply this rule to the upper block and class enclosing the enclosing type recursively
" 6. Accessible static fields imported.
"    It is allowed that several fields with the same name.

" The standard search order of a method is as follows:
" 1. Methods of the type
" 2. Accessible inherited methods.
" 3. Methods of the enclosing class if the type is a nested type.
" 4. Accessible static methods imported.
"    It is allowed that several methods with the same name and signature.

" first        return at once if found one.
" fullmatch    1 - equal, 0 - match beginning
" return [types, methods, fields, vars]
fu! s:SearchForName(name, first, fullmatch)
    let result = [[], [], [], []]
    if s:IsKeyword(a:name)
        return result
    endif

    " use java_parser.vim
    if javacomplete#GetSearchdeclMethod() == 4
        " declared in current file
        let unit = javacomplete#parse()

        let targetPos = java_parser#MakePos(line('.')-1, col('.')-1)
        let trees = s:SearchNameInAST(unit, a:name, targetPos, a:fullmatch)
        for tree in trees
            if tree.tag == 'VARDEF'
                call add(result[2], tree)
            elseif tree.tag == 'METHODDEF'
                call add(result[1], tree)
            elseif tree.tag == 'CLASSDEF'
                call add(result[0], tree.name)
            endif
        endfor

        if a:first && result != [[], [], [], []]    | return result | endif

        " Accessible inherited members
        let type = get(s:SearchTypeAt(unit, targetPos), -1, {})
        if !empty(type)
            let members = s:SearchMember(type, a:name, a:fullmatch, 2, 1, 0, 1)
            let result[0] += members[0]
            let result[1] += members[1]
            let result[2] += members[2]
        endif

        " static import
        let si = s:SearchStaticImports(a:name, a:fullmatch)
        let result[1] += si[1]
        let result[2] += si[2]
    endif
    return result
endfu

" TODO: how to determine overloaded functions
fu! s:DetermineMethod(methods, parameters)
    return get(a:methods, 0, {})
endfu

" Parser.GetType() in insenvim
function! s:GetDeclaredClassName(var)
    let var = s:Trim(a:var)
    if var =~# '^\(this\|super\)$'
        return var
    endif


    " Special handling for builtin objects in JSP
    if &ft == 'jsp'
        if get(s:JSP_BUILTIN_OBJECTS, a:var, '') != ''
            return s:JSP_BUILTIN_OBJECTS[a:var]
        endif
    endif

    " use java_parser.vim
    if javacomplete#GetSearchdeclMethod() == 4
        let variable = get(s:SearchForName(var, 1, 1)[2], -1, {})
        if get(variable, 'tag', '') == 'VARDEF'
            let tmp = java_parser#type2Str(variable.vartype)
            if type(variable.vartype) == type({})
                if get(variable.vartype, 'clazz', {}) != {} && variable.vartype.clazz.name == 'Entry' && get(variable.vartype.clazz, 'selected', {}) != {}
                    return variable.vartype.clazz.selected.name . "." . tmp
                else
                    return tmp
                endif
            else
                return tmp
            endif
        else
            return get(variable, 't', '')
        endif
        return get(variable, 'tag', '') == 'VARDEF' ? java_parser#type2Str(variable.vartype) : get(variable, 't', '')
    endif


    let ic = &ignorecase
    setlocal noignorecase

    let searched = javacomplete#GetSearchdeclMethod() == 2 ? s:Searchdecl(var, 1, 0) : searchdecl(var, 1, 0)
    if (searched == 0)
        " code sample:
        " String tmp; java.
        "     lang.  String str, value;
        " for (int i = 0, j = 0; i < 10; i++) {
        "   j = 0;
        " }
        let declaration = s:GetVariableDeclaration()
        " Assume it a class member, and remove modifiers
        let class = substitute(declaration, '^\(public\s\+\|protected\s\+\|private\s\+\|abstract\s\+\|static\s\+\|final\s\+\|native\s\+\)*', '', '')
        let class = substitute(class, '\s*\([a-zA-Z0-9_.]\+\)\(\[\]\)\?\s\+.*', '\1\2', '')
        let class = substitute(class, '\([a-zA-Z0-9_.]\)<.*', '\1', '')
        call s:Info('class: "' . class . '" declaration: "' . declaration . '" for ' . a:var)
        let &ignorecase = ic
        if class != '' && class !=# a:var && class !=# 'import' && class !=# 'class'
            return class
        endif
    endif

    let &ignorecase = ic
    return ''
endfunction

" using java_parser.vim                    {{{1
" javacomplete#parse()                    {{{2
fu! javacomplete#parse(...)
    let filename = a:0 == 0 ? '%' : a:1

    let changed = 0
    if filename == '%'
        let filename = s:GetCurrentFileKey()
        let props = get(s:files, filename, {})
        if get(props, 'changedtick', -1) != b:changedtick
            let changed = 1
            let props.changedtick = b:changedtick
            let lines = getline('^', '$')
        endif
    else
        let props = get(s:files, filename, {})
        if get(props, 'modifiedtime', 0) != getftime(filename)
            let changed = 1
            let props.modifiedtime = getftime(filename)
            let lines = readfile(filename)
        endif
    endif

    if changed
        call java_parser#InitParser(lines)
        call java_parser#SetLogLevel(5)
        let props.unit = java_parser#compilationUnit()
        let package = has_key(props.unit, 'package') ? props.unit.package . '.' : ''
        call s:UpdateFQN(props.unit, package)
    endif
    let s:files[filename] = props
    return props.unit
endfu

" update fqn for toplevel types or nested types. 
" not for local type or anonymous type
fu! s:UpdateFQN(tree, qn)
    if a:tree.tag == 'TOPLEVEL'
        for def in a:tree.types
            call s:UpdateFQN(def, a:qn)
        endfor
    elseif a:tree.tag == 'CLASSDEF'
        let a:tree.fqn = a:qn . a:tree.name
        if type(a:tree.defs) != type([])
            for def in a:tree.defs
                if def.tag == 'CLASSDEF'
                    call s:UpdateFQN(def, a:tree.fqn . '.')
                endif
            endfor
        endif
    endif
endfu

" TreeVisitor                        {{{2
fu! s:visitTree(tree, param) dict
    if type(a:tree) == type({})
        exe get(self, get(a:tree, 'tag', ''), '')
    elseif type(a:tree) == type([])
        for tree in a:tree
            call self.visit(tree, a:param)
        endfor
    endif
endfu

let s:TreeVisitor = {'visit': function('s:visitTree'),
                    \ 'TOPLEVEL'    : 'call self.visit(a:tree.types, a:param)',
                    \ 'BLOCK'    : 'let stats = a:tree.stats | if stats == [] | call java_parser#GotoPosition(a:tree.pos) | let stats = java_parser#block().stats | endif | call self.visit(stats, a:param)',
                        \ 'DOLOOP'    : 'call self.visit(a:tree.body, a:param) | call self.visit(a:tree.cond, a:param)',
                        \ 'WHILELOOP'    : 'call self.visit(a:tree.cond, a:param) | call self.visit(a:tree.body, a:param)',
                        \ 'FORLOOP'    : 'call self.visit(a:tree.init, a:param) | call self.visit(a:tree.cond, a:param) | call self.visit(a:tree.step, a:param) | call self.visit(a:tree.body, a:param)',
                        \ 'FOREACHLOOP'    : 'call self.visit(a:tree.var, a:param)  | call self.visit(a:tree.expr, a:param) | call self.visit(a:tree.body, a:param)',
                        \ 'LABELLED'    : 'call self.visit(a:tree.body, a:param)',
                        \ 'SWITCH'    : 'call self.visit(a:tree.selector, a:param) | call self.visit(a:tree.cases, a:param)',
                        \ 'CASE'    : 'call self.visit(a:tree.pat,  a:param) | call self.visit(a:tree.stats, a:param)',
                        \ 'SYNCHRONIZED': 'call self.visit(a:tree.lock, a:param) | call self.visit(a:tree.body, a:param)',
                        \ 'TRY'        : 'call self.visit(a:tree.body, a:param) | call self.visit(a:tree.catchers, a:param) | call self.visit(a:tree.finalizer, a:param) ',
                        \ 'CATCH'    : 'call self.visit(a:tree.param,a:param) | call self.visit(a:tree.body, a:param)',
                        \ 'CONDEXPR'    : 'call self.visit(a:tree.cond, a:param) | call self.visit(a:tree.truepart, a:param) | call self.visit(a:tree.falsepart, a:param)',
                        \ 'IF'        : 'call self.visit(a:tree.cond, a:param) | call self.visit(a:tree.thenpart, a:param) | if has_key(a:tree, "elsepart") | call self.visit(a:tree.elsepart, a:param) | endif',
                            \ 'EXEC'    : 'call self.visit(a:tree.expr, a:param)',
                            \ 'APPLY'    : 'call self.visit(a:tree.meth, a:param) | call self.visit(a:tree.args, a:param)',
                            \ 'NEWCLASS'    : 'call self.visit(a:tree.def, a:param)'
                            \}

let s:TV_CMP_POS = 'a:tree.pos <= a:param.pos && a:param.pos <= get(a:tree, "endpos", -1)'
let s:TV_CMP_POS_BODY = 'has_key(a:tree, "body") && a:tree.body.pos <= a:param.pos && a:param.pos <= get(a:tree.body, "endpos", -1)'

" Return a stack of enclosing types (including local or anonymous classes).
" Given the optional argument, return all (toplevel or static member) types besides enclosing types.
fu! s:SearchTypeAt(tree, targetPos, ...)
    let s:TreeVisitor.CLASSDEF    = 'if a:param.allNonLocal || ' . s:TV_CMP_POS . ' | call add(a:param.result, a:tree) | call self.visit(a:tree.defs, a:param) | endif'
    let s:TreeVisitor.METHODDEF    = 'if ' . s:TV_CMP_POS_BODY . ' | call self.visit(a:tree.body, a:param) | endif'
    let s:TreeVisitor.VARDEF    = 'if has_key(a:tree, "init") && !a:param.allNonLocal && ' . s:TV_CMP_POS . ' | call self.visit(a:tree.init, a:param) | endif'

    let result = []
    call s:TreeVisitor.visit(a:tree, {'result': result, 'pos': a:targetPos, 'allNonLocal': a:0 == 0 ? 0 : 1})
    return result
endfu

" Return a stack of enclosing types (including local or anonymous classes).
" Given the optional argument, return all (toplevel or static member) types besides enclosing types.
fu! s:SearchTypeByName(name, tree)
    let s:TreeVisitor.CLASSDEF    = 'if get(a:tree, "name", "") != "" && a:param.name =~ get(a:tree, "name", "") | call add(a:param.result, a:tree) | endif | call self.visit(a:tree.defs, a:param) '
    let s:TreeVisitor.METHODDEF    = 'if has_key(a:tree, "body") | call self.visit(a:tree.body, a:param) | endif'
    let s:TreeVisitor.VARDEF    = 'if has_key(a:tree, "init") | call self.visit(a:tree.init, a:param) | endif'

    let result = []
    call s:TreeVisitor.visit(a:tree, {'result': result, 'name': a:name})
    return result
endfu

" a:1        match beginning
" return    a stack of matching name
fu! s:SearchNameInAST(tree, name, targetPos, fullmatch)
    let comparator = a:fullmatch ? '==#' : '=~# "^" .'
    let cmd = 'if a:tree.name ' .comparator. ' a:param.name | call add(a:param.result, a:tree) | endif'
    let s:TreeVisitor.CLASSDEF    = 'if ' . s:TV_CMP_POS . ' | ' . cmd . ' | call self.visit(a:tree.defs, a:param) | endif'
    let s:TreeVisitor.METHODDEF    = cmd . ' | if ' . s:TV_CMP_POS_BODY . ' | call self.visit(a:tree.params, a:param) | call self.visit(a:tree.body, a:param) | endif'
    let s:TreeVisitor.VARDEF    = cmd . ' | if has_key(a:tree, "init") && ' . s:TV_CMP_POS . ' | call self.visit(a:tree.init, a:param) | endif'

    let result = []
    call s:TreeVisitor.visit(a:tree, {'result': result, 'pos': a:targetPos, 'name': a:name})
    return result
endfu


" javacomplete#Searchdecl                {{{2
" TODO:
fu! javacomplete#Searchdecl()
    let var  = expand('<cword>')

    let line = line('.')-1
    let col  = col('.')-1


    if var =~# '^\(this\|super\)$'
        if &ft == 'jsp'
            return ''
        endif

        let matchs = s:SearchTypeAt(javacomplete#parse(), java_parser#MakePos(line, col))

        let stat = s:GetStatement()
        for t in matchs
            if stat =~ t.name
                let coor = java_parser#DecodePos(t.pos)
                return var . '(' . (coor.line+1) . ',' . (coor.col) . ') ' . getline(coor.line+1)
            endif
        endfor
        if len(matchs) > 0
            let coor = java_parser#DecodePos(matchs[len(matchs)-1].pos)
            return var . '(' . (coor.line+1) . ',' . (coor.col) . ') ' . getline(coor.line+1)
        endif
        return ''
    endif

    " Type.this.
    " new Type()
    " new Type(param1, param2)
    " this.field
    " super.field

    let s:log = []


    " It may be an imported class.
    let imports = []
    for fqn in s:GetImports('imports_fqn')
        if fqn =~# '\<' . var . '\>$'
            call add(imports, fqn)
        endif
    endfor
    if len(imports) > 1
        echoerr 'Imports conflicts between ' . join(imports, ' and ')
    endif


    " Search in this buffer
    let matchs = s:SearchNameInAST(javacomplete#parse(), var, java_parser#MakePos(line, col), 1)


    let hint = var . ' '
    if !empty(matchs)
        let tree = matchs[len(matchs)-1]
        let coor = java_parser#DecodePos(tree.pos)
        let hint .=  '(' . (coor.line+1) . ',' . (coor.col) . ') '
        let hint .= getline(coor.line+1)        "string(tree)
    else
        for fqn in imports
            let ci = s:DoGetClassInfo(fqn)
            if !empty(ci)
                let hint .= ' ' . fqn
            endif
            " TODO: get javadoc
        endfor

    endif
    return hint
endfu


" java                            {{{1 
fu! s:IsBuiltinType(name)
    return index(s:PRIMITIVE_TYPES, a:name) >= 0
endfu

fu! s:IsKeyword(name)
    return index(s:KEYWORDS, a:name) >= 0
endfu

fu! s:HasKeyword(name)
    return a:name =~# s:RE_KEYWORDS
endfu

fu! s:TailOfQN(qn)
    return a:qn[strridx(a:qn, '.')+1:]
endfu

" options                                {{{1
" Methods to search declaration                        {{{2
"    1 - by builtin searchdecl()
"    2 - by special Searchdecl()
"    4 - by java_parser
fu! javacomplete#GetSearchdeclMethod()
    if &ft == 'jsp'
        return 1
    endif
    return exists('s:searchdecl') ? s:searchdecl : 4
endfu

fu! javacomplete#SetSearchdeclMethod(method)
    let s:searchdecl = a:method
endfu

" JDK1.1                                {{{2
fu! javacomplete#UseJDK11()
    let s:isjdk11 = 1
endfu

" jvm launcher                                {{{2
fu! javacomplete#GetJVMLauncher()
    return exists('s:interpreter') && s:interpreter !~  '^\s*$' ? s:interpreter : 'java'
endfu

fu! javacomplete#SetJVMLauncher(interpreter)
    if javacomplete#GetJVMLauncher() != a:interpreter
        let s:cache = {}
    endif
    let s:interpreter = a:interpreter
endfu

" sourcepath                                {{{2
fu! javacomplete#AddSourcePath(s)
    if !isdirectory(a:s)
        echoerr 'invalid source path: ' . a:s
        return
    endif
    let path = fnamemodify(a:s, ':p:h')
    if !exists('s:sourcepath')
        let s:sourcepath = [path]
    elseif index(s:sourcepath, path) == -1
        call add(s:sourcepath, path)
    endif
endfu

fu! javacomplete#DelSourcePath(s)
    if !exists('s:sourcepath') || !isdirectory(a:s)| return   | endif
    let idx = index(s:sourcepath, a:s)
    if idx != -1
        call remove(s:sourcepath, idx)
    endif
endfu

fu! javacomplete#SetSourcePath(s)
    let paths = type(a:s) == type([]) ? a:s : split(a:s, javacomplete#GetClassPathSep())
    let s:sourcepath = []
    for path in paths
        if isdirectory(path)
            call add(s:sourcepath, fnamemodify(path, ':p:h'))
        endif
    endfor
endfu

" return the sourcepath. Given argument, add current path or default package root path
" NOTE: Avoid path duplicate, otherwise globpath() will return duplicate result.
fu! javacomplete#GetSourcePath(...)
    return join(s:GetSourceDirs(a:0 > 0 && a:1 ? expand('%:p') : ''), s:PATH_SEP)
endfu

fu! s:GetSourceDirs(filepath, ...)
    let dirs = exists('s:sourcepath') ? s:sourcepath : []
    return dirs
endfu

" classpath                                {{{2
fu! javacomplete#AddClassPath(s)
    if !exists('s:classpath')
        let s:classpath = [a:s]
    elseif index(s:classpath, a:s) == -1
        call add(s:classpath, a:s)
    endif
    let s:cache = {}
endfu

fu! javacomplete#DelClassPath(s)
    if !exists('s:classpath') | return   | endif
    let idx = index(s:classpath, a:s)
    if idx != -1
        call remove(s:classpath, idx)
    endif
endfu

fu! javacomplete#SetClassPath(s)
    if type(a:s) == type("")
        let s:classpath = split(a:s, javacomplete#GetClassPathSep())
    elseif type(a:s) == type([])
        let s:classpath = a:s
    endif
    let s:cache = {}
endfu

fu! javacomplete#GetClassPathSep()
    return s:PATH_SEP
endfu

fu! javacomplete#GetClassPath()
    return exists('s:classpath') ? join(s:classpath, javacomplete#GetClassPathSep()) : ''
endfu

" s:GetClassPath()                            {{{2
fu! s:GetClassPath()
    let path = javacomplete#GetClassPathSep()

    if exists('b:classpath') && b:classpath !~ '^\s*$'
        return path . b:classpath
    endif

    if exists('s:classpath')
        return path . javacomplete#GetClassPath()
    endif

    if exists('g:java_classpath') && g:java_classpath !~ '^\s*$'
        return path . g:java_classpath
    endif

    return path . $CLASSPATH
endfu

" return only classpath which are directories
fu! s:GetClassDirs()
    let dirs = []
    for path in split(s:GetClassPath(), s:PATH_SEP)
        if isdirectory(path)
            call add(dirs, fnamemodify(path, ':p:h'))
        endif
    endfor
    return dirs
endfu

" s:GetPackageName()                            {{{2
fu! s:GetPackageName()
    let lnum_old = line('.')
    let col_old = col('.')

    call cursor(1, 1)
    let lnum = search('^\s*package[ \t\r\n]\+\([a-zA-Z][a-zA-Z0-9.]*\);', 'w')
    let packageName = substitute(getline(lnum), '^\s*package\s\+\([a-zA-Z][a-zA-Z0-9.]*\);', '\1', '')

    call cursor(lnum_old, col_old)
    return packageName
endfu

fu! s:IsStatic(modifier)
    return a:modifier[strlen(a:modifier)-4]
endfu

" utilities                            {{{1
" Convert a file name into the unique form.
" Similar with fnamemodify(). NOTE that ':gs' should not be used.
fu! s:fnamecanonize(fname, mods)
    return fnamemodify(a:fname, a:mods . ':gs?[\\/]\+?/?')
endfu

" Similar with filter(), but returns a new list instead of operating in-place.
" `item` has the value of the current item.
fu! s:filter(expr, string)
    if type(a:expr) == type([])
        let result = []
        for item in a:expr
            if eval(a:string)
                call add(result, item)
            endif
        endfor
        return result
    else
        let result = {}
        for item in items(a:expr)
            if eval(a:string)
                let result[item[0]] = item[1]
            endif
        endfor
        return result
    endif
endfu

fu! s:Index(list, expr, key)
    let i = 0
    while i < len(a:list)
        if get(a:list[i], a:key, '') == a:expr
            return i
        endif
        let i += 1
    endwhile
    return -1
endfu

fu! s:Match(list, expr, key)
    let i = 0
    while i < len(a:list)
        if get(a:list[i], a:key, '') =~ a:expr
            return i
        endif
        let i += 1
    endwhile
    return -1
endfu

fu! s:KeepCursor(cmd)
    let lnum_old = line('.')
    let col_old = col('.')
    exe a:cmd
    call cursor(lnum_old, col_old)
endfu

fu! s:InCommentOrLiteral(line, col)
    if has("syntax") && &ft != 'jsp'
        return synIDattr(synID(a:line, a:col, 1), "name") =~? '\(Comment\|String\|Character\)'
    endif
endfu

function! s:InComment(line, col)
    if has("syntax") && &ft != 'jsp'
        return synIDattr(synID(a:line, a:col, 1), "name") =~? 'comment'
    endif
endfunction

" set string literal empty, remove comments, trim begining or ending spaces
" test case: '     sb. /* block comment*/ append( "stringliteral" ) // comment '
function! s:Prune(str, ...)
    if a:str =~ '^\s*$' | return '' | endif

    let str = substitute(a:str, '"\(\\\(["\\''ntbrf]\)\|[^"]\)*"', '""', 'g')
    let str = substitute(str, '\/\/.*', '', 'g')
    let str = s:RemoveBlockComments(str)
    return a:0 > 0 ? str : str . ' '
endfunction

" Given argument, replace block comments with spaces of same number
fu! s:RemoveBlockComments(str, ...)
    let result = a:str
    let ib = match(result, '\/\*')
    let ie = match(result, '\*\/')
    while ib != -1 && ie != -1 && ib < ie
        let result = strpart(result, 0, ib) . (a:0 == 0 ? ' ' : repeat(' ', ie-ib+2)) . result[ie+2: ]
        let ib = match(result, '\/\*')
        let ie = match(result, '\*\/')
    endwhile
    return result
endfu

fu! s:Trim(str)
    let str = substitute(a:str, '^\s*', '', '')
    return substitute(str, '\s*$', '', '')
endfu

fu! s:SplitAt(str, index)
    return [strpart(a:str, 0, a:index+1), strpart(a:str, a:index+1)]
endfu

" TODO: search pair used in string, like 
"     'create(ao.fox("("), new String).foo().'
function! s:GetMatchedIndexEx(str, idx, one, another)
    let pos = a:idx
    while 0 <= pos && pos < len(a:str)
        let pos = match(a:str, '['. a:one . escape(a:another, ']') .']', pos+1)
        if pos != -1
            if a:str[pos] == a:one
                let pos = s:GetMatchedIndexEx(a:str, pos, a:one, a:another)
            elseif a:str[pos] == a:another
                break
            endif
        endif
    endwhile
    return 0 <= pos && pos < len(a:str) ? pos : -3
endfunction

function! s:SearchPairBackward(str, idx, one, another)
    let idx = a:idx
    let n = 0
    while idx >= 0
        let idx -= 1
        if a:str[idx] == a:one
            if n == 0
                break
            endif
            let n -= 1
        elseif a:str[idx] == a:another  " nested 
            let n += 1
        endif
    endwhile
    return idx
endfunction

fu! s:CountDims(str)
    if match(a:str, '[[\]]') == -1
        return 0
    endif

    " int[] -> [I, String[] -> 
    let dims = len(matchstr(a:str, '^[\+'))
    if dims == 0
        let idx = len(a:str)-1
        while idx >= 0 && a:str[idx] == ']'
            let dims += 1
            let idx = s:SearchPairBackward(a:str, idx, '[', ']')-1
        endwhile
    endif
    return dims
endfu

fu! s:GotoUpperBracket()
    let searched = 0
    while (!searched)
        call search('[{}]', 'bW')
        if getline('.')[col('.')-1] == '}'
            normal %
        else
            let searched = 1
        endif
    endwhile
endfu

" Improve recognition of variable declaration using my version of searchdecl() for accuracy reason.
" TODO:
fu! s:Searchdecl(name, ...)
    let global = a:0 > 0 ? a:1 : 0
    let thisblock = a:0 > 1 ? a:2 : 1

    call search('\<' . a:name . '\>', 'bW')
    let lnum_old = line('.')
    let col_old = col('.')

    call s:GotoUpperBracket()
    let lnum_bracket = line('.')
    let col_bracket = col('.')
    call search('\<' . a:name . '\>', 'W', lnum_old)
    if line('.') != lnum_old || col('.') != col_old
        return 0
    endif

    " search globally
    if global
        call cursor(lnum_bracket, col_bracket)
        " search backward
        while (1)
            if search('\([{}]\|\<' . a:name . '\>\)', 'bW') == 0
                break
            endif
            if s:InComment(line('.'), col('.')) "|| s:InStringLiteral()
                continue
            endif
            let cword = expand('<cword>')
            if cword == a:name
                return 0
            endif
            if getline('.')[col('.')-1] == '}'
                normal %
            endif
        endwhile

        call cursor(lnum_old, col_old)
        " search forward
        call search('[{};]', 'W')
        while (1)
            if search('\([{}]\|\<' . a:name . '\>\)', 'W') == 0
                break
            endif
            if s:InComment(line('.'), col('.')) "|| s:InStringLiteral()
                continue
            endif
            let cword = expand('<cword>')
            if cword == a:name
                return 0
            endif
            if getline('.')[col('.')-1] == '{'
                normal %
            endif
        endwhile
    endif
    return 1
endfu

fu! javacomplete#Exe(cmd)
    exe a:cmd
endfu

" cache utilities                            {{{1

" key of s:files for current buffer. It may be the full path of current file or the bufnr of unnamed buffer, and is updated when BufEnter, BufLeave.
fu! s:GetCurrentFileKey()
    return has("autocmd") ? s:curfilekey : empty(expand('%')) ? bufnr('%') : expand('%:p')
endfu

fu! s:SetCurrentFileKey()
    let s:curfilekey = empty(expand('%')) ? bufnr('%') : expand('%:p')
endfu

call s:SetCurrentFileKey()
if has("autocmd")
    autocmd BufEnter *.java call s:SetCurrentFileKey()
    autocmd BufWritePost *.java call s:UpdateImportsCache(s:curfilekey)
    autocmd FileType java call s:SetCurrentFileKey()
endif


" Log utilities                                {{{1
" level
"     5    off/fatal 
"     4    error 
"     3    warn
"     2    info
"     1    debug
"     0    trace
fu! javacomplete#SetLogLevel(level)
    let s:loglevel = a:level
endfu

fu! javacomplete#GetLogLevel()
    return exists('s:loglevel') ? s:loglevel : 3
endfu

fu! javacomplete#GetLogContent()
    return s:log
endfu

fu! s:Trace(msg)
    call s:Log(0, a:msg)
endfu

fu! s:Debug(msg)
    call s:Log(1, a:msg)
endfu

fu! s:Info(msg)
    call s:Log(2, a:msg)
endfu

fu! s:Log(level, key, ...)
    if a:level >= -1 "javacomplete#GetLogLevel() -1
ruby <<EOF
        key = VIM::evaluate("a:key")
        File.open("#{ENV['HOME']}/javacomplete.txt", "a+") { |f|
          f.write(key + "\n")
        }
EOF
    endif
endfu

" functions to get information                        {{{1
" utilities                                {{{2
fu! s:MemberCompare(m1, m2)
    return a:m1['n'] == a:m2['n'] ? 0 : a:m1['n'] > a:m2['n'] ? 1 : -1
endfu

fu! s:Sort(ci)
    let ci = a:ci
    if has_key(ci, 'fields')
        call sort(ci['fields'], 's:MemberCompare')
    endif
    if has_key(ci, 'methods')
        call sort(ci['methods'], 's:MemberCompare')
    endif
    return ci
endfu

" Function to run VimTool                        {{{2
fu! s:RunVimTool(option, args, log)
    let cmd = g:javacomplete_ng . ' org.vimsense.VimTool --nailgun-port ' . g:nailgun_port . ' -sources ' . javacomplete#GetSourcePath() . ' -classes ' . s:GetClassPath() . ' ' . a:option . ' ' . a:args . ''
    return s:System(cmd, a:log)
endfu

fu! s:System(cmd, caller)
    call s:Trace(a:cmd)
    let t = reltime()
    let res = system(a:cmd)
    return res
endfu

" class information                            {{{2


" The standard search order of a FQN is as follows:
" 1. a file-name toplevel type or static member type accessed by the file-name type declared in source files
" 2. other types declared in source files
" 3. an accessible loadable type.
" parameters:
"   fqns    - list of fqn
"   srcpaths    - a comma-separated list of directory names.
"   a:1        - search all.
" return    a dict of fqn -> type info
" precondition: 
" NOTE: call expand() to convert path to standard form
fu! s:DoGetTypeInfoForFQN(fqns, srcpath, ...)
    call s:Trace('DoGetTypeInfoForFQN fqn in VimTool: ' . string(a:fqns))
    if empty(a:fqns)
        return
    endif

    "call s:Info('FQN1&2: ' . string(keys(files)))
    for fqn in a:fqns
        call s:Trace("DoGetTypeInfoForFQN fqn for: ** " . fqn)
        if stridx(fqn, ".") >= 0
        endif
        if !has_key(s:cache, fqn) " || get(get(s:files, files[fqn], {}), 'modifiedtime', 0) != getftime(files[fqn])
            let ti = s:GetClassInfoFromSource(fqn, '')
            if !empty(ti)
                let s:cache[fqn] = s:Sort(ti)
            endif
        else
            call s:Trace("FOUND !!!" . fqn)
        endif
        "if (a:0 == 0 || !a:1)
            "call s:Trace("FUCKY")
            "return
        "endif
    endfor

    " 3
    call s:Trace("after what should have been")
    let commalist = ''
    for fqn in a:fqns
        if has_key(s:cache, fqn) && (a:0 == 0 || !a:1)
            return
        else "if stridx(fqn, '.') >= 0
            let commalist .= fqn . ','
        endif
    endfor
    if !empty(commalist)
        let res = s:RunVimTool('-E', '-class ' . commalist, 'DoGetTypeInfoForFQN in Batch')
        if res =~ "^{'"
            let dict = eval(res)
            for key in keys(dict)
                if !has_key(s:cache, key)
                    if type(dict[key]) == type({})
                        let s:cache[key] = s:Sort(dict[key])
                    elseif type(dict[key]) == type([])
                        let s:cache[key] = sort(dict[key])
                    endif
                endif
            endfor
        endif
    endif
endfu

" a:1    filepath
" a:2    package name
fu! s:DoGetClassInfo(class, ...)
    if has_key(s:cache, a:class)
        return s:cache[a:class]
    endif

    " array type:    TypeName[] or '[I' or '[[Ljava.lang.String;'
    if a:class[-1:] == ']' || a:class[0] == '['
        return s:ARRAY_TYPE_INFO
    endif

    " either this or super is not qualified
    if a:class == 'this' || a:class == 'super'
        if &ft == 'jsp'
            let ci = s:DoGetReflectionClassInfo('javax.servlet.jsp.HttpJspPage')
            if a:class == 'this'
                " TODO: search methods defined in <%! [declarations] %>
                "	search methods defined in other jsp files included
                "	avoid including self directly or indirectly
            endif
            return ci
        endif

        call s:Info('A0. ' . a:class)
        " this can be a local class or anonymous class as well as static type
        let t = get(s:SearchTypeAt(javacomplete#parse(), java_parser#MakePos(line('.')-1, col('.')-1)), -1, {})
        if !empty(t)
            " What will be returned for super?
            " - the protected or public inherited fields and methods. No ctors.
            " - the (public static) fields of interfaces.
            " - the methods of the Object class.
            " What will be returned for this?
            " - besides the above, all fields and methods of current class. No ctors.
            return s:Sort(s:Tree2ClassInfo(t))
        endif

        return {}
    endif


    if a:class !~ '^\s*' . s:RE_QUALID . '\s*$' || s:HasKeyword(a:class)
        return {}
    endif


    let typename    = substitute(a:class, '\s', '', 'g')
    let filekey    = a:0 > 0 ? a:1 : s:GetCurrentFileKey()
    let packagename = a:0 > 1 ? a:2 : s:GetPackageName()
    let srcpath    = join(s:GetSourceDirs(a:0 > 0 && a:1 != bufnr('%') ? a:1 : expand('%:p'), packagename), ',')

    let names = split(typename, '\.')
    " remove the package name if in the same packge
    if len(names) > 1
        if packagename == join(names[:-2], '.')
            let names = names[-1:]
        endif
    endif

    " a FQN
    if len(names) > 1
        call s:DoGetTypeInfoForFQN([typename], srcpath)
        let ci = get(s:cache, typename, {})
        if get(ci, 'tag', '') == 'CLASSDEF'
            return s:cache[typename]
        elseif get(ci, 'tag', '') == 'PACKAGE'
            return {}
        endif
    endif


    " The standard search order of a simple type name is as follows:
    " 1. The current type including inherited types.
    " 2. A nested type of the current type.
    " 3. Explicitly named imported types (single type import).
    " 4. Other types declared in the same package. Not only current directory.
    " 5. Implicitly named imported types (import on demand).

    " 1 & 2.
    " NOTE: inherited types are treated as normal
    if filekey == s:GetCurrentFileKey()
        let simplename = typename[strridx(typename, '.')+1:]
        if s:FoundClassDeclaration(simplename) != 0
            call s:Info('A1&2')
            let ci = s:GetClassInfoFromSource(simplename, '%')
            " do not cache it
            if !empty(ci)
                return ci
            endif
        endif
    else
        let ci = s:GetClassInfoFromSource(typename, filekey)
        if !empty(ci)
            return ci
        endif
    endif

    " 3.
    " NOTE: PackageName.Ident, TypeName.Ident
    let fqn = s:SearchSingleTypeImport(typename, s:GetImports('imports_fqn', filekey))
    if !empty(fqn)
        call s:Info('A3')
        call s:DoGetTypeInfoForFQN([fqn], srcpath)
        let ti = get(s:cache, fqn, {})
        if get(ti, 'tag', '') != 'CLASSDEF'
            " TODO: mark the wrong import declaration.
        endif
        return ti
    endif

    " 4 & 5
    " NOTE: Keeps the fqn of the same package first!!
    call s:Info('A4&5')
    call s:Trace("typename: " . typename)
    call s:Trace("packagename: " . packagename)
    call s:Trace("class: " . a:class)
    let fqns = [empty(packagename) ? typename : packagename . '.' . typename]
    for p in s:GetImports('imports_star', filekey)
        call s:Trace("@@@@@@@@@@@@@@@@@@@@ imports_star: " . p . typename)
        call add(fqns, p . typename)
    endfor
    call s:Info("After A4&5: " . string(fqns))
    call s:DoGetTypeInfoForFQN(fqns, srcpath)
    for fqn in fqns
        if has_key(s:cache, fqn)
            return get(s:cache[fqn], 'tag', '') == 'CLASSDEF' ? s:cache[fqn] : {}
        endif
    endfor

    return {}
endfu

" Parameters:
"   class    the qualified class name
" Return:    TClassInfo or {} when not found
" See ClassInfoFactory.getClassInfo() in insenvim.
function! s:DoGetReflectionClassInfo(fqn)
    if !has_key(s:cache, a:fqn)
        let res = s:RunVimTool('-C', a:fqn, 's:DoGetReflectionClassInfo')
        if res =~ '^{'
            let s:cache[a:fqn] = s:Sort(eval(res))
        elseif res =~ '^['
            for type in eval(res)
                if get(type, 'name', '') != ''
                    let s:cache[type.name] = s:Sort(type)
                endif
            endfor
        else
            let b:errormsg = res
        endif
    endif
    return get(s:cache, a:fqn, {})
endfunction

fu! s:GetClassInfoFromSource(class, filename)
    call s:Trace("GetClassInfoFromSource: " . a:class)
    let ci = {}

    let res = s:RunVimTool('-C -single', '-class ' . a:class, 's:GetClassInfoFromSource')
    if res == ""
        let ci = {}
    else
        call s:Trace("GetClassInfoFromSource: " . string(res))
        let ci = eval(res)
        if type(ci) == type({})
              let ci = s:Sort(ci)
        endif
    endif

    return ci
endfu

fu! s:Tree2ClassInfo(t)
    let t = a:t

    " fill fields and methods
    let t.fields = []
    let t.methods = []
    let t.ctors = []
    let t.classes = []
    for def in t.defs
        if def.tag == 'METHODDEF'
            call add(def.n == t.name ? t.ctors : t.methods, def)
        elseif def.tag == 'VARDEF'
            call add(t.fields, def)
        elseif def.tag == 'CLASSDEF'
            call add(t.classes, t.fqn . '.' . def.name)
        endif
    endfor

    " convert type name in extends to fqn for class defined in source files
    if !has_key(a:t, 'classpath') && has_key(a:t, 'parent')
        if has_key(a:t, 'filepath') && a:t.filepath != s:GetCurrentFileKey()
            let filepath = a:t.filepath
            let packagename = get(s:files[filepath].unit, 'package', '')
        else
            let filepath = expand('%:p')
            let packagename = s:GetPackageName()
        endif

        let extends = a:t.parent
        let i = 0
        while i < len(extends)
            let ci = s:DoGetClassInfo(java_parser#type2Str(extends[i]), filepath, packagename)
            if has_key(ci, 'fqn')
                let extends[i] = ci.fqn
            endif
            let i += 1
        endwhile
    endif

    return t
endfu

" To obtain information of the class in current file or current folder, or
" even in current project.
function! s:DoGetClassInfoFromTags(class)
    " find tag of a:class declaration
    let tags = taglist('^' . a:class)
    let filename = ''
    let cmd = ''
    for tag in tags
        if has_key(tag, 'kind')
            if tag['kind'] == 'c'
                let filename = tag['filename']
                let cmd = tag['cmd']
                break
            endif
        endif
    endfor

    let tags = taglist('^' . (empty(b:incomplete) ? '.*' : b:incomplete) )
    if filename != ''
        call filter(tags, "v:val['filename'] == '" . filename . "' && has_key(v:val, 'class') ? v:val['class'] == '" . a:class . "' : 1")
    endif

    let ci = {'name': a:class}
    " extends and implements
    let ci['ctors'] = []
    let ci['fields'] = []
    let ci['methods'] = []

    " members
    for tag in tags
        let member = {'n': tag['name']}

        " determine kind
        let kind = 'm'
        if has_key(tag, 'kind')
            let kind = tag['kind']
        endif

        let cmd = tag['cmd']
        if cmd =~ '\<static\>'
            let member['m'] = '1000'
        else
            let member['m'] = ''
        endif

        let desc = substitute(cmd, '/^\s*', '', '')
        let desc = substitute(desc, '\s*{\?\s*$/$', '', '')

        if kind == 'm'
            " description
            if cmd =~ '\<static\>'
                let desc = substitute(desc, '\s\+static\s\+', ' ', '')
            endif
            let member['d'] = desc

            let member['p'] = ''
            let member['r'] = ''
            if tag['name'] == a:class
                call add(ci['ctors'], member)
            else
                call add(ci['methods'], member)
            endif
        elseif kind == 'f'
            let member['t'] = substitute(desc, '\([a-zA-Z0-9_[\]]\)\s\+\<' . tag['name'] . '\>.*$', '\1', '')
            call add(ci['fields'], member)
        endif
    endfor
    return ci
endfu

" package information                            {{{2

fu! s:DoGetPackageInfoByReflection(class, option)
    if has_key(s:cache, a:class)
        return s:cache[a:class]
    endif

    if a:class == '-'
        let res = s:RunVimTool(a:option, '', 's:DoGetPackageInfoByReflection')
    else
        let res = s:RunVimTool(a:option, '-class ' . a:class, 's:DoGetPackageInfoByReflection')
    endif
    if res =~ '^[{\[]'
        let v = eval(res)
        if type(v) == type([])
            let s:cache[a:class] = sort(v)
        elseif type(v) == type({})
            if get(v, 'tag', '') =~# '^\(PACKAGE\|CLASSDEF\)$'
                let s:cache[a:class] = v
            else
                call extend(s:cache, v, 'force')
            endif
        endif
        unlet v
    else
        let b:errormsg = res
    endif

    return get(s:cache, a:class, {})
endfu

" search in members                            {{{2
" TODO: what about default access?
" public for all              
" protected for this or super 
" private for this            
fu! s:CanAccess(mods, kind)
    return (a:mods[-4:-4] || a:kind/10 == 0)
                \ &&   (a:kind == 1 || a:mods[-1:]
                \    || (a:mods[-3:-3] && (a:kind == 1 || a:kind == 2))
                \    || (a:mods[-2:-2] && a:kind == 1))
endfu

fu! s:SearchMember(ci, name, fullmatch, kind, returnAll, memberkind, ...)
    let result = [[], [], []]

    if a:kind != 13
        for m in (a:0 > 0 && a:1 ? [] : get(a:ci, 'fields', [])) + ((a:kind == 1 || a:kind == 2) ? get(a:ci, 'declared_fields', []) : [])
            if empty(a:name) || (a:fullmatch ? m.n ==# a:name : m.n =~# '^' . a:name)
                if s:CanAccess(m.m, a:kind)
                    call add(result[2], m)
                endif
            endif
        endfor

        for m in (a:0 > 0 && a:1 ? [] : get(a:ci, 'methods', [])) + ((a:kind == 1 || a:kind == 2) ? get(a:ci, 'declared_methods', []) : [])
            if empty(a:name) || (a:fullmatch ? m.n ==# a:name : m.n =~# '^' . a:name)
                if s:CanAccess(m.m, a:kind)
                    call add(result[1], m)
                endif
            endif
        endfor
    endif

    if a:kind/10 != 0
        let types = get(a:ci, 'classes', [])
        for t in types
            if empty(a:name) || (a:fullmatch ? t[strridx(t, '.')+1:] ==# a:name : t[strridx(t, '.')+1:] =~# '^' . a:name)
                if !has_key(s:cache, t) || !has_key(s:cache[t], 'flags') || a:kind == 1 || s:cache[t].flags[-1:]
                    call add(result[0], t)
                endif
            endif
        endfor
    endif

    " key `classpath` indicates it is a loaded class from classpath
    " All public members of a loaded class are stored in current ci
    if !has_key(a:ci, 'classpath') || (a:kind == 1 || a:kind == 2)
        for i in get(a:ci, 'parent', [])
            let ci = s:DoGetClassInfo(java_parser#type2Str(i))
            let members = s:SearchMember(ci, a:name, a:fullmatch, a:kind == 1 ? 2 : a:kind, a:returnAll, a:memberkind)
            let result[0] += members[0]
            let result[1] += members[1]
            let result[2] += members[2]
        endfor
    endif
    return result
endfu


" generate member list                            {{{2

fu! s:DoGetFieldList(fields)
    let s = ''
    for field in a:fields
        let s .= "{'kind':'" . (s:IsStatic(field.m) ? "F" : "f") . "','word':'" . field.n . "','menu':'" . field.t . "','dup':1},"
    endfor
    return s
endfu

fu! s:DoGetMethodList(methods, ...)
    let paren = a:0 == 0 || !a:1 ? '(' : ''
    let s = ''
    for method in a:methods
        let s .= "{'kind':'" . (s:IsStatic(method.m) ? "M" : "m") . "','word':'" . method.n . paren . "','abbr':'" . method.n . "()','menu':'" . method.d . "','dup':'1'},"
    endfor
    return s
endfu

" kind:
"    0 - for instance, 1 - this, 2 - super, 3 - class, 4 - array, 5 - method result, 6 - primitive type
"    11 - for type, with `class` and static member and nested types.
"    12 - for import static, no lparen for static methods
"    13 - for import or extends or implements, only nested types
"    20 - for package
fu! s:DoGetMemberList(ci, kind)
    if type(a:ci) != type({}) || a:ci == {}
        return []
    endif

    let s = a:kind == 11 ? "{'kind': 'C', 'word': 'class', 'menu': 'Class'}," : ''

    let members = s:SearchMember(a:ci, '', 1, a:kind, 1, 0, a:kind == 2)

    " add accessible member types
    if a:kind / 10 != 0
        " Use dup here for member type can share name with field.
        for class in members[0]
            let v = get(s:cache, class, {})
            if v == {} || v.flags[-1:]
                let s .= "{'kind': 'C', 'word': '" . substitute(class, a:ci.name . '\.', '\1', '') . "','dup':1},"
            endif
        endfor
    endif

    if a:kind != 13
        let fieldlist = []
        let sfieldlist = []
        for field in members[2]
            if s:IsStatic(field['m'])
                call add(sfieldlist, field)
            elseif a:kind / 10 == 0
                call add(fieldlist, field)
            endif
        endfor

        let methodlist = []
        let smethodlist = []
        for method in members[1]
            if s:IsStatic(method['m'])
                call add(smethodlist, method)
            elseif a:kind / 10 == 0
                call add(methodlist, method)
            endif
        endfor

        if a:kind / 10 == 0
            let s .= s:DoGetFieldList(fieldlist)
            let s .= s:DoGetMethodList(methodlist)
        endif
        let s .= s:DoGetFieldList(sfieldlist)
        let s .= s:DoGetMethodList(smethodlist, a:kind == 12)

        let s = substitute(s, '\<' . a:ci.name . '\.', '', 'g')
        let s = substitute(s, '\<java\.lang\.', '', 'g')
        let s = substitute(s, '\<\(public\|static\|synchronized\|transient\|volatile\|final\|strictfp\|serializable\|native\)\s\+', '', 'g')
    endif
    return eval('[' . s . ']')
endfu

" interface                            {{{2

function! s:GetMemberList(class)
    if s:IsBuiltinType(a:class)
        return []
    endif

    return s:DoGetMemberList(s:DoGetClassInfo(a:class), 0)
endfunction

fu! s:GetStaticMemberList(class)
    return s:DoGetMemberList(s:DoGetClassInfo(a:class), 11)
endfu

function! s:GetConstructorList(class)
    let ci = s:DoGetClassInfo(a:class)
    if empty(ci)
        return []
    endif

    let s = ''
    for ctor in get(ci, 'ctors', [])
        let s .= "{'kind': '+', 'word':'". a:class . "(','abbr':'" . ctor.d . "','dup':1},"
    endfor

    let s = substitute(s, '\<java\.lang\.', '', 'g')
    let s = substitute(s, '\<public\s\+', '', 'g')
    return eval('[' . s . ']')
endfunction

" Name can be a (simple or qualified) package name, or a (simple or qualified)
" type name.
fu! s:GetMembers(fqn, ...)
    let list = []
    let isClass = 0

    let v = s:DoGetPackageInfoByReflection(a:fqn, '-E')
    if type(v) == type([])
        let list = v
    elseif type(v) == type({}) && v != {}
        if get(v, 'tag', '') == 'PACKAGE'
            if b:context_type == s:CONTEXT_IMPORT_STATIC || b:context_type == s:CONTEXT_IMPORT
                call add(list, {'kind': 'P', 'word': '*;'})
            endif
            if b:context_type != s:CONTEXT_PACKAGE_DECL
                for c in sort(get(v, 'classes', []))
                    call add(list, {'kind': 'C', 'word': c})
                endfor
            endif
            for p in sort(get(v, 'subpackages', []))
                call add(list, {'kind': 'P', 'word': p})
            endfor
        else
            let isClass = 1
            let list += s:DoGetMemberList(v, b:context_type == s:CONTEXT_IMPORT || b:context_type == s:CONTEXT_NEED_TYPE ? 13 : b:context_type == s:CONTEXT_IMPORT_STATIC ? 12 : 11)
        endif
    endif

    if !isClass
        "let list += s:DoGetPackageInfoInDirs(a:fqn, b:context_type == s:CONTEXT_PACKAGE_DECL)
    endif

    return list
endfu

" }}}
"}}}
" vim:set fdm=marker sw=4 ts=4 si expandtab nowrap:
