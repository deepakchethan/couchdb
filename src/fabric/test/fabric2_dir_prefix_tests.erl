% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

-module(fabric2_dir_prefix_tests).

-include_lib("couch/include/couch_eunit.hrl").
-include_lib("eunit/include/eunit.hrl").
-include("fabric2_test.hrl").

dir_prefix_test_() ->
    {
        "Test couchdb fdb directory prefix",
        setup,
        fun() ->
            % erlfdb, ctrace are all dependent apps for fabric. We make
            % sure to start them so when fabric is started during the test it
            % already has its dependencies
            test_util:start_couch([erlfdb, ctrace, fabric])
        end,
        fun(Ctx) ->
            config:delete("fabric", "fdb_directory"),
            test_util:stop_couch(Ctx)
        end,
        with([
            ?TDEF(default_prefix, 15),
            ?TDEF(custom_prefix, 15)
        ])
    }.

default_prefix(_) ->
    erase(fdb_directory),
    ok = config:delete("fabric", "fdb_directory", false),
    ok = application:stop(fabric),
    ok = application:start(fabric),

    ?assertEqual([<<"couchdb">>], fabric2_server:fdb_directory()),

    % Try again to test pdict caching code
    ?assertEqual([<<"couchdb">>], fabric2_server:fdb_directory()),

    % Check that we can create dbs
    DbName = ?tempdb(),
    ?assertMatch({ok, _}, fabric2_db:create(DbName, [])).

custom_prefix(_) ->
    erase(fdb_directory),
    ok = config:set("fabric", "fdb_directory", "couchdb_foo", false),
    ok = application:stop(fabric),
    ok = application:start(fabric),

    ?assertEqual([<<"couchdb_foo">>], fabric2_server:fdb_directory()),

    % Try again to test pdict caching code
    ?assertEqual([<<"couchdb_foo">>], fabric2_server:fdb_directory()),

    % Check that we can create dbs
    DbName = ?tempdb(),
    ?assertMatch({ok, _}, fabric2_db:create(DbName, [])).
