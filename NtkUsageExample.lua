{
    /system script run "JParseFunctions";
    :global JSONUnload;

    /system script run "NotakeyFunctions";
    :global NtkAuthRequest;
    :global NtkWaitFor;
    :global NtkUnload;

    :local ntkHost "demo.notakey.com";
    :local ntkAccessId "12345645-b32b-4788-a00d-251cd7dc9a03";
    :local ntkUser "demo";

    :local ntkAuthUuid ([$NtkAuthRequest host=$ntkHost accessId=$ntkAccessId authUser=$ntkUser]);

    :if ([$NtkWaitFor uuid=$ntkAuthUuid host=$ntkHost accessId=$ntkAccessId]) do={
        :put "All cool, we are letting you in";
    } else={
        :put "Auth expired or denied"
    }

    $NtkUnload
    $JSONUnload
}