# Mnesia Clustering#

This document describes how to 

* Initialize DB replicated Mnesia cluster
* Dynamically add Mnesia node to existing Mnesia cluster 

## Sample Program ##
The sample program code base is from [Erlang replication test](http://blog.maxkit.com.tw/2014/09/erlang-mnesia-replication.html) and was modified based on [分散DBMS「Mnesia」の並列処理(Japanese)](http://internetcom.jp/developer/20100511/26.html) . 

## Prerequesites ##

* Erlang runtime installed.
* Nodes initialized 
	* Create node folders (e.g. node1, node2,...)
	* Copy [test_mnesia.erl](https://github.com/sypannapis/mnesia-clustering-test/blob/master/test_mnesia.erl) to created node folders 
	* `erl -sname <node_name>`
	* `(node_name@hostname)1> c(test_mnesia).`

##Add cluster nodes at beginning##

Given 2 nodes, _Node1_ and _Node2_

####Node1####

1. Connect to node2
2. Create schema and table. This step add schema and table to every nodes connected to node1
3. Start Mnesia database
4. Add testing data

```erlang
test_mnesia:connect_node('node2@hostname').
test_mnesia:create_schema_and_table(). 
test_mnesia:start().
test_mnesia:add_test_data().
```

####Node2####

1. Start Mnesia database
2. Validate if data replicated to node2 successfully.

```erlang
test_mnesia:start().
test_mnesia:show_shop_table().
```

## Add cluster nodes by change_config ##

####Node2####

```erlang
test_mnesia:start().
```

The function is a blocking code with N minute timeout for incoming `mnesia:add_table_copy()` request (N is currently 2). During the timeout, switch back to Node1 for next command. 

####Node1####

`add_node()` invokes `mnesia:add_table_copy()`.

```erlang
test_mnesia:add_node('node2@hostname').
```

####Node2####

Validate if data replicated to node2 successfully.

```erlang
test_mnesia:show_shop_table().
```