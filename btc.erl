-module(btc).
-export([
    start_mining/0, mine/2, 
    check_hash/2, get_leading/1,
    main_node_mine/2, update_main_node_coin/2,
    join_as_worker/0, worker_mine/2,
    main_node_list/2, main_node/0, spawn_miners/2
    ]).

main_node() ->
    'dish@192.168.0.9'.

main_node_list(BitcoinList, LeadingZeroes) ->
    receive
        {getlist, From} ->
            From ! BitcoinList,
            main_node_list([], LeadingZeroes);
        {getleading, From} ->
            From ! LeadingZeroes,
            main_node_list(BitcoinList, LeadingZeroes);
        {updatelist, {Coin, Hash}} ->
            NewBitcoinList = lists:append(BitcoinList, [{Coin, Hash}]),
            main_node_list(NewBitcoinList, LeadingZeroes);
        {isalive, From} ->
            From ! alive,
            main_node_list(BitcoinList, LeadingZeroes);
        die ->
            io:format("Shutting Down Main Node~n",[]),
            exit(normal)
    end.

worker_mine(Leading, MineCount) ->
    if 
        MineCount > 100 ->
            {main_node_list, main_node()} ! {isalive, self()},
            receive
                alive ->
                    ok
            after 5000 ->
                io:format("Main Node Ended~n", []),
                exit(normal)
            end;
        true ->
            ok
    end,
    Coin = string:trim(string:concat("dishankpoddar;", base64:encode_to_string(base64:encode(crypto:strong_rand_bytes(32)))), trailing, "=0"),
    [Bitcoin, Hash] = check_hash(Coin, Leading),
    if
        Bitcoin ->
            {main_node_list, main_node()} ! {isalive, self()},
            receive
                alive ->    
                    ok
            after 5000 ->
                io:format("Main Node Ended~n", []),
                exit(normal)
            end,
            {main_node_list, main_node()} ! {updatelist, {Coin, Hash}},
            worker_mine(Leading, 0);
        true ->
            worker_mine(Leading, MineCount + 1)
    end.



join_as_worker() ->
    {main_node_list, main_node()} ! {isalive, self()},
    receive
        alive ->
            ok
    after 5000 ->
        io:format("Main Node Not Started~n", []),
        exit(normal)
    end,
    {main_node_list, main_node()} ! {getleading, self()},
    receive
        Leading ->
            Kernels=erlang:system_info(schedulers_online),
            spawn_miners(Kernels,Leading)
            % spawn(btc, worker_mine, [Leading, 0])        
    after 5000 ->
        io:format("Main Node Not Responding~n", []),
        exit(timeout)
    end.

update_main_node_coin(ExistingCoins, []) ->
    ExistingCoins;
update_main_node_coin(ExistingCoins, [{Coin, Hash} | RemainingMainNodeBitcoinList]) ->
    Exists = lists:member(Coin, ExistingCoins),
    if 
        not Exists ->
            io:format("~s ~s from worker~n",[Coin, Hash]),
            NewExistingCoins = lists:append(ExistingCoins, [Coin]);
        true ->
            NewExistingCoins = ExistingCoins 
    end,
    update_main_node_coin(NewExistingCoins, RemainingMainNodeBitcoinList).


main_node_mine(ExistingCoins, Leading) ->
    Coin = string:trim(string:concat("dishankpoddar;", base64:encode_to_string(base64:encode(crypto:strong_rand_bytes(32)))), trailing, "=0"),
    [Bitcoin, Hash] = check_hash(Coin, Leading),
    Exists = lists:member(Coin, ExistingCoins),
    if
        Bitcoin and not Exists ->
            NewExistingCoins = lists:append(ExistingCoins, [Coin]),
            io:format("~s ~s~n",[Coin, Hash]);
        true ->
            NewExistingCoins = ExistingCoins
    end,
    main_node_list ! {getlist, self()},
    receive
        MainNodeBitcoinList ->
            UpdatedNewExistingCoins = update_main_node_coin(NewExistingCoins, MainNodeBitcoinList)
    after 5000 ->
        io:format("Main Node List Not Responding~n", []),
        UpdatedNewExistingCoins = NewExistingCoins,
        exit(timeout)
    end,
    if
        length(UpdatedNewExistingCoins) < 100 ->
            main_node_mine(UpdatedNewExistingCoins, Leading);
        true ->
            main_node_list ! die
    end.

get_leading(0) ->
    "";
get_leading(N) ->
    string:concat("0",get_leading(N - 1)).

check_hash(Coin, Leading) ->
    Hash = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256,Coin))]),
    [string:find(Hash, Leading) =:= Hash, Hash].
    
    
mine(ExistingCoins, Leading) ->
    Coin = string:trim(string:concat("dishankpoddar;", base64:encode_to_string(base64:encode(crypto:strong_rand_bytes(32)))), trailing, "=0"),
    [Bitcoin, Hash] = check_hash(Coin, Leading),
    Exists = lists:member(Coin, ExistingCoins),
    if
        Bitcoin and not Exists ->
            NewExistingCoins = lists:append(ExistingCoins, [Coin]),
            io:format("~s ~s ~s~n",[Coin, Hash, node()]);
        true ->
            NewExistingCoins = ExistingCoins
    end,
    if
        length(NewExistingCoins) < 100 ->
            mine(NewExistingCoins, Leading);
        true ->
            ok
    end.

spawn_miners(1,Leading) ->
    spawn(btc,worker_mine,[Leading,0]);
spawn_miners(Kernels,Leading) ->
    spawn(btc,worker_mine,[Leading,0]),
    spawn_miners(Kernels-1,Leading).

start_mining() ->
    {ok, LeadingZeroes} = io:read("Enter number of leading 0s for a coin: "),
    Leading = get_leading(LeadingZeroes),
    ExistingCoins = [],
    Kernels=erlang:system_info(schedulers_online),
    io:format("~p",[Kernels]),
    register(main_node_list, spawn(btc, main_node_list, [ExistingCoins, Leading])),
    statistics(runtime),
    statistics(wall_clock),
    spawn_miners(Kernels,Leading),        
    main_node_mine(ExistingCoins,Leading),
    {_,Time1} = statistics(runtime),
    {_,Time2} = statistics(wall_clock),
    io:format("The work took ~p cpu milliseconds and ~p wall clock milliseconds", [Time1, Time2]).
    % spawn(btc, main_node_mine, [ExistingCoins, Leading]).
    