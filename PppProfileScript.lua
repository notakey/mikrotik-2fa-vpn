# OnUp script
{
    :local localAddr $"local-address";
    :local remoteAddr $"remote-address";
    :local callerId $"caller-id";
    :local calledId $"called-id";

    :log info "$user (srcIp=$callerId, dstIp=$calledId) connected: was given $remoteAddr IP (GW $localAddr)";

    /system script run "JParseFunctions";
    :global JSONUnload;

    /system script run "NotakeyFunctions";
    :global NtkAuthRequest;
    :global NtkWaitFor;
    :global NtkUnload;

    # Change values below to match your Notakey installation

    # ntkHost - https hostname of Notakey Authentication Server (NtkAS)
    :local ntkHost "demo.notakey.com";

    # ntkAccessId - service ID of NtkAS, can be seen in settings
    :local ntkAccessId "12345645-b32b-4788-a00d-251cd7dc9a03";

    # Custom message in authentication request
    :local authDescMsg "Log in as $user from $callerId\?";

    :local ntkAuthUuid ([$NtkAuthRequest host=$ntkHost accessId=$ntkAccessId authUser=$user authTitle="VPN connection" authDesc=$authDescMsg authTtl=60]);

    :if ([$NtkWaitFor uuid=$ntkAuthUuid host=$ntkHost accessId=$ntkAccessId]) do={
        :put "All cool, we are letting you in";
        # Remove blocking rule after successful 2FA autehntication
        /ip firewall address-list remove [/ip firewall address-list find where list=vpn_pending address=$remoteAddr]
    } else={
        :log info "VPN 2FA authentication failure for user $user from IP $callerId";
        # Disconnect active session with this IP and user
        /ppp active remove [/ppp active find name="$user" address="$remoteAddr"]
    }

    $NtkUnload
    $JSONUnload
}

# OnDown script
{
    # Just logs the disconnect event, not in use right now

    :local localAddr $"local-address";
    :local remoteAddr $"remote-address";
    :local callerId $"caller-id";
    :local calledId $"called-id";

    :log info "$user (srcIp=$callerId, dstIp=$calledId) logged out: was given $remoteAddr IP (GW $localAddr)";
}