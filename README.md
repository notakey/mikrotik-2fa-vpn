# MikroTik client library for Notakey two factor authentication

Allows to integrate push notification based two factor authentication using Notakey Authenticator mobile app
for iOS or Android in various MikroTik workflows, mainly targeted for VPN strong authentication.

Note that you will need additional firewall or routing setup to use this solution to approve authentication
from the same device as the VPN is initiated on, e.g. start vpn and approve from the same device.

## Installation

* Install JParseFunctions library
  - Create JParseFunctions script on your MikroTik router (no privilledges required)
  - Copy contents from [JParseFunctions.lua](https://github.com/Winand/mikrotik-json-parser/raw/master/JParseFunctions) file into this script

* Install NotakeyFunctions library
  - Create NotakeyFunctions script on your MikroTik router (no privilledges required)
  - Copy contents from NotakeyFunctions.lua file in this repository into this script

* Enable two factor authentication inside PPP profile that your VPN service uses (usually default-encryption)
  - Copy Up and Down scripts from PppProfileScript.lua into profile
  - Adjust Notakey Autehntication Server parameters (ntkHost & ntkAccessId)
  - Adjust firewall rules according to your setup

## Generic usage example
```
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
    :local ntkHost "demoapi.example.com";

    # ntkAccessId - service ID of NtkAS, can be seen in settings
    :local ntkAccessId "12345645-b32b-4788-a00d-251cd7dc9a03";

    # Custom message in authentication request
    :local authDescMsg "Log in as $user from $callerId\?";

    :local ntkAuthUuid ([$NtkAuthRequest host=$ntkHost accessId=$ntkAccessId authUser=$user]);

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
```

This script can be copied into MikroTik Terminal shell to test the functionality of scripts. Please remember to adjust Authentication Server params.

## Dependencies:

* JParseFunctions [https://github.com/Winand/mikrotik-json-parser]
* Hosted or on-premises Notakey Authentication Appliance installation
* iOS or Android device with onboarded service
* Username in onboarded service must match the one used for VPN authentication
* Fairly modern RouterOS >= v6.46.4

## Limitations

* Due to limitations of JParseFunctions library, you cannot use parentheses and possibly other special punctuation in authentication requests
* Currently you also cannot have multiple consecutive spaces in authentication request text fields (action and description)


## Links

* Documentation [http://docs.notakey.com/]
* Contact [https://notakey.com/]
* Support [support@notakey.com]
