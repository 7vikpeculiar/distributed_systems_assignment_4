-module(merge).
-export([print_helper/2,main/1,scan_input/1,mergeSort/1, parallelMergeSort/2, parallelMergeSort/4, individualMerge/3,looper/3]).

mergeSort([]) -> [];
mergeSort(L) when length(L) == 1 -> L;
mergeSort(L) when length(L) > 1 ->
    {L1, L2} = lists:split(length(L) div 2, L),
    lists:merge(mergeSort(L1), mergeSort(L2)).

looper(I, Num_procs, Lis) when I < Num_procs -> 
    receive
        {sent_msg, SortedList} -> 
            MergedList = lists:merge(Lis, SortedList),
            looper(I+1, Num_procs, MergedList)
    end;
looper(I, Num_procs, Lis) when I == Num_procs ->
    Lis.

parallelMergeSort(L,Num_procs) when length(L) < Num_procs -> mergeSort(L);

parallelMergeSort(L, Num_procs) when length(L) >= Num_procs -> 
    parallelMergeSort(L, length(L), Num_procs,1),
    Output = looper(0,Num_procs,[]),
    Output.


parallelMergeSort(L, OrigLength, Num_procs, I) when I < Num_procs -> 
    {L1, L2} = lists:split(OrigLength div (Num_procs-1), L),
    register(list_to_atom(integer_to_list(I)),spawn(merge, individualMerge, [self(), I, L1])),
    parallelMergeSort(L2,OrigLength, Num_procs, I+1);

parallelMergeSort(L, OrigLength, Num_procs, I) when I == Num_procs -> 
    register(list_to_atom(integer_to_list(I)),spawn(merge, individualMerge, [self(), I, L])),
    ok.

individualMerge(SrcId, I, L) -> 
    SortedList = mergeSort(L),
    SrcId ! {sent_msg, SortedList}.

% So, each proc is spawLisned and registered && merge is called
% After that the main proc receives 

scan_input(Filename) ->
    {ok, IoDevice} = file:open(Filename, [read]),
    Inpa = io:get_line(IoDevice,''),   
    file:close(IoDevice),
    % Inpa = io:get_line(''),
    lists:map(fun(X) -> {Int, _} = string:to_integer(X), 
                    Int end, 
          string:tokens(Inpa, [$\s, $\n])).

print_helper(OutStream,[]) ->
    % io:format("~n"),
    ok;
print_helper(OutStream,[H|T]) ->
    io:format(OutStream,"~p ",[H]),
    print_helper(OutStream,T).

main(InpLis) ->
    InpFilename = lists:nth(1,InpLis),
    OutFilename = lists:nth(2,InpLis),
    Output = parallelMergeSort(scan_input(InpFilename),16),
    {ok, OutStream} = file:open(OutFilename, [write]),
    print_helper(OutStream, Output),
    file:close(OutStream),
    ok.