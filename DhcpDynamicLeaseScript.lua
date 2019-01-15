#
# This script runs when new DHCP clients register and request authorization for dynamic clients.
# If authorization is provided, a static lease is created and no more autorization is requested for
# further client connections.
# To install, copy script into DHCP server lease script field.
#
{
    :local dynLease [ /ip dhcp-server lease get [/ip dhcp-server lease find mac-address="$leaseActMAC"] dynamic ];
    :if ($dynLease) do={
        :if ($leaseBound = "1") do={
            :local hostName [/ip dhcp-server lease get [/ip dhcp-server lease find mac-address="$leaseActMAC"] host-name ];

            :if ($hostName."test" = "test") do={
                :set hostName "no hostname"
            }

            # Block traffic to router from this DHCP address
            # Remove old address, previously blocked, just in case
            /ip firewall filter remove [/ip firewall filter find where comment="auto-dhcp-rule-$leaseServerName-$leaseActIP"]
            /ip firewall filter add action=reject chain=input src-address="$leaseActIP" reject-with=icmp-admin-prohibited comment="auto-dhcp-rule-$leaseServerName-$leaseActIP"

            /system script run "JParseFunctions";
            :global JSONUnload;

            /system script run "NotakeyFunctions";
            :global NtkAuthRequest;
            :global NtkWaitFor;
            :global NtkUnload;

            # Change values below to match your Notakey installation
            # ntkHost - https hostname of Notakey Authentication Server (NtkAS)
            :local ntkHost "demo.notakey.com";
            # Change to your Notakey username
            :local ntkUser "mainadmin"
            # ntkAccessId - service ID of NtkAS, can be seen in settings
            :local ntkAccessId "12345645-b32b-4788-a00d-251cd7dc9a03";
            # Custom message in authentication request
            :local authDescMsg "Allow access to for $hostName with MAC $leaseActMAC and IP $leaseActIP\?";
            :local authTitleMsg "New DHCP client"

            :local ntkAuthUuid ([$NtkAuthRequest host=$ntkHost accessId=$ntkAccessId authUser=$ntkUser authTitle=$authTitleMsg authDesc=$authDescMsg authTtl=7200]);

            :if ([$NtkWaitFor uuid=$ntkAuthUuid host=$ntkHost accessId=$ntkAccessId]) do={
                # Remove blocking rule after successful 2FA autehntication
                /ip firewall filter remove [/ip firewall filter find where comment="auto-dhcp-rule-$leaseServerName-$leaseActIP"]
                /ip dhcp-server lease make-static [ /ip dhcp-server lease find where address="$leaseActIP" ]
            } else={
                :log info "DHCP client with MAC $leaseActMAC forbidden access by $ntkUser";
            }

            $NtkUnload
            $JSONUnload
        }
    }
}