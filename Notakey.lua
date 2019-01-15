#
# Creates a new authentication request to NAS for specified user
# Params:
#   host - hostname of NAS server
#   accessId - ID of NAS service, can be found in NAS dashboard
#   authUser - username that will receive approval request
#
:global NtkAuthRequest;
if (!any $NtkAuthRequest) do={ :global NtkAuthRequest do={
    :do {
        # API request response payload
        :local content;
        # Auth request UUID
        :local uuid;

        :global JSONLoads;
        :if ([:len $JSONLoads] = 0) do={
            :log error "NotakeyFunctions: JSONLoads empty, have you loaded JParseFunctions?";
            :put "ERROR JSONLoads empty, have you loaded JParseFunctions?";
            :error "ERROR JSONLoads empty, have you loaded JParseFunctions?";
        }

        :if (([:len $host] = 0) || ([:len $authUser] = 0) || ([:len $accessId] = 0)) do={
            :log error "NotakeyFunctions: One or more required params empty, please pass host,accessId,authUser params";
            :put "ERROR One or more required params empty, please pass host,accessId,authUser params";
            :error "ERROR One or more required params empty, please pass host,accessId,authUser params";
        }

        :local lauthTitle $authTitle;
        :local lauthDesc $authDesc;
        :local lauthTtl $authTtl;

        :if ([:len $lauthDesc] = 0) do={
            :set lauthDesc "Do you wish to proceed with authentication as user $authUser?";
        }

        :if ([:len $lauthTitle] = 0) do={
            :set lauthTitle "MikroTik Authentication";
        }

        :if ([:len $lauthTtl] = 0) do={
            :set lauthTtl 300;
        }

        :local result [/tool fetch mode=https url="https://$host/api/v2/application/$accessId/application_user/$authUser/auth_request" http-content-type="application/json" http-method=post  http-data="{\"action\": \"$lauthTitle\", \"description\": \"$lauthDesc\", \"ttl_seconds\": \"$lauthTtl\"}" as-value output=user];

        :if ($result->"status" != "finished") do={
            :log error "NotakeyFunctions: Notakey auth request creation request failed";
            :put "ERROR Notakey auth request creation request failed";
            :error "ERROR Notakey auth request creation request failed";
        }

        :set content ($result->"data");
        :set uuid ([$JSONLoads $content]->"uuid");
        # Clear payload contents
        :set content;

        :if ([:len $uuid] = 0) do={
            :log error "NotakeyFunctions: Notakey UUID missing";
            :put "ERROR Notakey UUID missing, have you loaded JParseFunctions?";
            :error "ERROR Notakey UUID missing, have you loaded JParseFunctions?";
        }

        :log info "NotakeyFunctions: Notakey Auth request $uuid created";
        :put "Notakey Auth request $uuid created";
        :return $uuid;
    } on-error={
        :log error "NotakeyFunctions: Notakey Auth request send error";
        :put "ERROR Notakey Auth request send error";
    }
}}

#
# Waits until specified auth request identified by uuid is approved or rejected or expires
# Params:
#   host - hostname of NAS server
#   uuid - ID of auth request, returned by NtkAuthRequest
#   accessId - ID of NAS service, can be found in NAS dashboard
#
:global NtkWaitFor;
if (!any $NtkWaitFor) do={ :global NtkWaitFor do={
    :do {
        :local hasResponse false;
        :local responseType "null";
        :local requestExpired false;
        :local content;

        :global JSONLoads;
        :if ([:len $JSONLoads] = 0) do={
            :log error "NotakeyFunctions: JSONLoads empty, have you loaded JParseFunctions?";
            :put "ERROR JSONLoads empty, have you loaded JParseFunctions?";
            :error "ERROR JSONLoads empty, have you loaded JParseFunctions?";
        }

        :if (([:len $host] = 0) || ([:len $uuid] = 0) || ([:len $accessId] = 0)) do={
            :log error "NotakeyFunctions: One or more required params empty, please pass host,accessId,uuid params";
            :put "ERROR One or more required params empty, please pass host,accessId,uuid params";
            :error "ERROR One or more required params empty, please pass host,accessId,uuid params";
        }

        :do {
            :local result [/tool fetch mode=https url="https://$host/api/v2/application/$accessId/auth_request/$uuid" http-content-type="application/json" http-method=get as-value output=user];
            :set content ($result->"data");
            :set responseType ([$JSONLoads $content]->"response_type");
            :local requestExpired ([$JSONLoads $content]->"expired");
            # Clear payload contents
            :set content;

            :put ("Check $uuid status, response: $responseType, expired: $requestExpired")
            :if ([:len $responseType] > 0) do={
                :set hasResponse true;
            }

            :if ($requestExpired) do={
                :set hasResponse true;
            }

            :delay 2;
        } while=( $hasResponse = false )

        :if ($requestExpired) do={
            :log warn "NotakeyFunctions: Notakey Auth request expired with no response";
            :put "ERROR Notakey Auth request expired with no response";
            :error "Notakey Auth request expired with no response";
        }

        :if ($responseType = "ApproveRequest") do={
            :log info "NotakeyFunctions: Notakey Auth request $uuid approved";
            :put "Notakey Auth request $uuid approved";
            :return true;
        }

        :log info "NotakeyFunctions: Notakey Auth request $uuid denied";
        :put "Notakey Auth request $uuid denied";
        :return false;
    } on-error={
        :log error "NotakeyFunctions: Notakey Authentication procedure not successful";
        :put "ERROR Authentication procedure not successful";
    }
}}

#
# Unloads Notakey gobal functions
#
:global NtkUnload;
if (!any $NtkUnload) do={ :global NtkUnload do={
    :global NtkWaitFor;
    :set NtkWaitFor;
    :global NtkAuthRequest;
    :set NtkAuthRequest;
    :global NtkUnload;
    :set NtkUnload;
}}