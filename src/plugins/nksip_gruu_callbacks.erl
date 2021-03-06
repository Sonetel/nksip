%% -------------------------------------------------------------------
%%
%% Copyright (c) 2019 Carlos Gonzalez Florido.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @doc NkSIP GRUU Plugin Callbacks
-module(nksip_gruu_callbacks).
-author('Carlos Gonzalez <carlosj.gf@gmail.com>').

-include("nksip.hrl").
-include("nksip_call.hrl").
-include("nksip_registrar.hrl").
-export([nksip_registrar_request_opts/2, nksip_registrar_update_regcontact/4,
         nksip_uac_response/4]).



%% ===================================================================
%% Specific
%% ===================================================================


%% @private
nksip_registrar_request_opts(#sipmsg{ srv_id=SrvId, contacts=Contacts}=Req, Opts) ->
    Config = nksip_config:srv_config(SrvId),
    case
        lists:member(<<"gruu">>, Config#config.supported) andalso
        nksip_sipmsg:supported(<<"gruu">>, Req)
    of
        true ->
        	lists:foreach(
        		fun(Contact) -> nksip_gruu_lib:check_gr(Contact, Req) end,
        		Contacts),
        	{continue, [Req, [{gruu, true}|Opts]]};
        false ->
        	{continue, [Req, Opts]}
    end.


%% @private
nksip_registrar_update_regcontact(RegContact, Base, Req, Opts) ->
	RegContact1 = nksip_gruu_lib:update_regcontact(RegContact, Base, Req, Opts),
    {continue, [RegContact1, Base, Req, Opts]}.


%% @private
nksip_uac_response(Req, Resp, UAC, Call) ->
    nksip_gruu_lib:update_gruu(Resp),
    {continue, [Req, Resp, UAC, Call]}.