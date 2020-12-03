# MikroTik client library for Notakey two factor authentication

Allows to integrate push notification based two factor authentication using Notakey Authenticator mobile app
for iOS or Android in various MikroTik workflows, mainly targeted for VPN strong authentication.

Note that you will need additional firewall or routing setup to use this solution to approve authentication
from the same device as the VPN is initiated on, e.g. start vpn and approve from the same device.

## Installation

* Install JParseFunctions library
  - Create JParseFunctions script on your MikroTik router (no privilledges required)
  - Copy contents from JParseFunctions.lua file into this script

* Install NotakeyFunctions library
  - Create NotakeyFunctions script on your MikroTik router (no privilledges required)
  - Copy contents from Notakey.lua file in this repository into this script

* Enable two factor authentication inside PPP profile that your VPN service uses (usually default-encryption)
  - Copy Up and Down scripts from PppProfileScript.lua into profile
  - Adjust Notakey Autehntication Server parameters (ntkHost & ntkAccessId)
  - Adjust firewall rules according to your setup

## Generic usage example
```
{
    # Load dependencies first
    /system script run "JParseFunctions";
    :global JSONUnload;

    # Load Notakey function library
    /system script run "NotakeyFunctions";
    :global NtkAuthRequest;
    :global NtkWaitFor;
    :global NtkUnload;

    # Set Notakey Authentication Server params
    :local ntkHost "demo.notakey.com";
    :local ntkAccessId "12345645-b32b-4788-a00d-251cd7dc9a03";
    :local ntkUser "demo";

    # Send autehntication request to mobile device
    :local ntkAuthUuid ([$NtkAuthRequest host=$ntkHost accessId=$ntkAccessId authUser=$ntkUser]);

    # Wait for response from mobile
    :if ([$NtkWaitFor uuid=$ntkAuthUuid host=$ntkHost accessId=$ntkAccessId]) do={
        :put "All cool, we are letting you in";
    }else{
        :put "Auth expired or denied"
    }

    # Unload global function references
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
