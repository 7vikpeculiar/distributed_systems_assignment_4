-module('20161163_1').
-export([read_text_file/1, mini_loop/2,get_pid/1,loop/1,main/1,zero_loop/1]).

loop(Val) ->
    receive
        {send_token, {OutFileName, SrcPid, Us, Token_val}} ->
            {ok, IoDevice} = file:open(OutFileName, [append]),
            io:fwrite(IoDevice,"Process ~p received token ~p from process ~p.~n",[Us, Token_val, SrcPid]),
            file:close(IoDevice), 
            get_pid((Us+1) rem Val) ! {send_token, {OutFileName, Us,(Us+1) rem Val, Token_val}};
        _ ->     % All other messages
            loop(Val)
    end.

zero_loop(Val) ->
    receive 
        {send_token, {OutFileName, SrcPid, Us, Token_val}} ->
            get_pid((Us+1) rem Val) ! {send_token, {OutFileName, Us,(Us+1) rem Val, Token_val}};
        _ -> % All other messages
            zero_loop(Val)
    end,

    receive
        {send_token, {OutFileName2, SrcPid2, Us2, Token_val2}} ->
            {ok, IoDevice} = file:open(OutFileName2, [append]),
            io:fwrite(IoDevice,"Process ~p received token ~p from process ~p.~n",[Us2, Token_val2, SrcPid2]),
            file:close(IoDevice);
        _ -> % All other messages
            loop(Val)
    end.

mini_loop(0,M) ->
    M,
    ok;

mini_loop(1,M) ->
    register(list_to_atom(integer_to_list(0)),spawn('20161163_1', zero_loop, [M]));

mini_loop(N,M) ->
    register(list_to_atom(integer_to_list(N-1)),spawn('20161163_1', loop, [M])),
    mini_loop(N-1,M).


main(InpLis) ->
    InpFileName = lists:nth(1,InpLis),
    OutFileName = lists:nth(2,InpLis),
    [N, Token_val] = read_text_file(InpFileName),    
    if N > 1 -> 
        mini_loop(N,N),
        {ok, IoDevice} = file:open(OutFileName, [write]),
        file:close(IoDevice),
        get_pid(0) ! {send_token, {OutFileName, -1, 0, Token_val}}, 
        ok;
    true -> 
        io:format("Invalid number of processes~n")
    end.


read_text_file(Filename) ->
    {ok, IoDevice} = file:open(Filename, [read]),
    {ok, [N,Token_val]} = io:fread(IoDevice,'',"~d ~d"),    
    file:close(IoDevice),
    [N, Token_val].

get_pid(A) ->
    whereis(list_to_atom(integer_to_list(A))).
