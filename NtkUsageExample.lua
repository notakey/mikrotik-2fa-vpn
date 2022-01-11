{
    :local localAddr $"local-address";
    :local remoteAddr $"remote-address";
    :local callerId $"caller-id";
    :local calledId $"called-id";

    /system script run "JParseFunctions";
    :global JSONUnload;

    /system script run "NotakeyFunctions";
    :global NtkAuthRequest;
    :global NtkWaitFor;
    :global NtkUnload;

    :log info "$user (srcIp=$callerId, dstIp=$calledId) connected: was given $remoteAddr IP (GW $localAddr)";

    # Change values below to match your Notakey installation
    # ntkHost - https hostname of Notakey Authentication Server (NtkAS)
    :local ntkHost "demo.notakey.com";

    # ntkAccessId - service ID of NtkAS, can be seen in settings
    :local ntkAccessId "12345645-b32b-4788-a00d-251cd7dc9a03";

    # Custom message in authentication request
    :local ntkUser "demo";

    :local ntkAuthUuid ([$NtkAuthRequest host=$ntkHost accessId=$ntkAccessId authUser=$ntkUser]);

    :if ([$NtkWaitFor uuid=$ntkAuthUuid host=$ntkHost accessId=$ntkAccessId]) do={
        :log info "VPN 2FA authentication success for user $user from IP $callerId ($remoteAddr)";
        # Removes user IP from 2fa_pending access list (configure access list in PPP profile)
        /ip firewall address-list remove [/ip firewall address-list find where list=2fa_pending address=$remoteAddr]
    } else={
        :log info "VPN 2FA authentication failure for user $user from IP $callerId";
        # Disconnect active session with this IP and user
        /ppp active remove [/ppp active find name="$user" address="$remoteAddr"]
    }

    $NtkUnload
    $JSONUnload
}