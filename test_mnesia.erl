%%%-------------------------------------------------------------------
%%% @author andersonchen
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Dec 2015 5:17 PM
%%%-------------------------------------------------------------------
-module(test_mnesia).
-import(lists, [foreach/2]).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").

-record(shop, {item, quantity, cost}).
-record(cost, {name, price}).
-record(design, {id, plan}).

create_schema_and_table() ->
  %%% mnesia:delete_schema([node()| nodes()]),
  mnesia:create_schema([node()| nodes()]),
  mnesia:start(),
  mnesia:create_table(shop,   [{ram_copies, [node()| nodes()]},{attributes, record_info(fields, shop)}]),
  mnesia:create_table(cost,   [{ram_copies, [node()| nodes()]},{attributes, record_info(fields, cost)}]),
  mnesia:create_table(design, [{ram_copies, [node()| nodes()]},{attributes, record_info(fields, design)}]),
  mnesia:stop(),
  mnesia:system_info().

connect_node(Name) ->
  net_adm:ping(Name),
  nodes().

start() ->
  mnesia:start(),
  mnesia:wait_for_tables([shop,cost,design], 120000).

stop() ->
  mnesia:stop().

add_node(Name) ->
  connect_node(Name),
  mnesia:change_config(extra_db_nodes,[Name]),
  mnesia:add_table_copy(shop,Name,disc_copies),
  mnesia:add_table_copy(cost,Name,ram_copies),
  mnesia:add_table_copy(design,Name,ram_copies).

add_test_data() ->
  mnesia:clear_table(shop),
  mnesia:clear_table(cost),
  F = fun() ->
    foreach(fun mnesia:write/1, example_tables())
      end,
  mnesia:transaction(F).

example_tables() ->
  [%% The shop table
    {shop, apple,   20,   2.3},
    {shop, orange,  100,  3.8},
    {shop, pear,    200,  3.6},
    {shop, banana,  420,  4.5},
    {shop, potato,  2456, 1.2},
    %% The cost table
    {cost, apple,   1.5},
    {cost, orange,  2.4},
    {cost, pear,    2.2},
    {cost, banana,  1.5},
    {cost, potato,  0.6}
  ].

show_shop_table() ->
  do(qlc:q([X || X <- mnesia:table(shop)])).

add_shop_item(Name, Quantity, Cost) ->
  Row = #shop{item=Name, quantity=Quantity, cost=Cost},
  F = fun() ->
    mnesia:write(Row)
      end,
  mnesia:transaction(F).

do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.