# MikroTik client library for Notakey two factor authentication

Allows to integrate push notification based two factor authentication based on Notakey Authenticator mobile app
for iOS or Android in various MikroTik workflows, mainly targeted for VPN strong authentication.

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

    # Set Notakey Autehntication Server params
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

## Dependencies:

* JParseFunctions [https://github.com/Winand/mikrotik-json-parser]
* Hosted or on-premises Notakey Authentication Appliance installation
* iOS or Android device with onboarded service
* Username in onboarded service must match the one used for VPN authentication
* Fairly modern RouterOS >= 6.43.x

## Links

* Documentation [http://docs.notakey.com/]
* Contact [https://notakey.com/]
* Support [support@notakey.com]