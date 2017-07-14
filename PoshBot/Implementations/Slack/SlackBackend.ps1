
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope='Class', Target='*')]
class SlackBackend : Backend {

    # The types of message that we care about from Slack
    # All othere will be ignored
    [string[]]$MessageTypes = @('channel_rename', 'message', 'pin_added', 'pin_removed', 'presence_change', 'reaction_added', 'reaction_removed', 'star_added', 'star_removed')

    [int]$MaxMessageLength = 4000

    # Import some color defs.
    hidden [hashtable]$_PSSlackColorMap = @{
        aliceblue = "#F0F8FF"
        antiquewhite = "#FAEBD7"
        aqua = "#00FFFF"
        aquamarine = "#7FFFD4"
        azure = "#F0FFFF"
        beige = "#F5F5DC"
        bisque = "#FFE4C4"
        black = "#000000"
        blanchedalmond = "#FFEBCD"
        blue = "#0000FF"
        blueviolet = "#8A2BE2"
        brown = "#A52A2A"
        burlywood = "#DEB887"
        cadetblue = "#5F9EA0"
        chartreuse = "#7FFF00"
        chocolate = "#D2691E"
        coral = "#FF7F50"
        cornflowerblue = "#6495ED"
        cornsilk = "#FFF8DC"
        crimson = "#DC143C"
        darkblue = "#00008B"
        darkcyan = "#008B8B"
        darkgoldenrod = "#B8860B"
        darkgray = "#A9A9A9"
        darkgreen = "#006400"
        darkkhaki = "#BDB76B"
        darkmagenta = "#8B008B"
        darkolivegreen = "#556B2F"
        darkorange = "#FF8C00"
        darkorchid = "#9932CC"
        darkred = "#8B0000"
        darksalmon = "#E9967A"
        darkseagreen = "#8FBC8F"
        darkslateblue = "#483D8B"
        darkslategray = "#2F4F4F"
        darkturquoise = "#00CED1"
        darkviolet = "#9400D3"
        deeppink = "#FF1493"
        deepskyblue = "#00BFFF"
        dimgray = "#696969"
        dodgerblue = "#1E90FF"
        firebrick = "#B22222"
        floralwhite = "#FFFAF0"
        forestgreen = "#228B22"
        fuchsia = "#FF00FF"
        gainsboro = "#DCDCDC"
        ghostwhite = "#F8F8FF"
        gold = "#FFD700"
        goldenrod = "#DAA520"
        gray = "#808080"
        green = "#008000"
        greenyellow = "#ADFF2F"
        honeydew = "#F0FFF0"
        hotpink = "#FF69B4"
        indianred = "#CD5C5C"
        indigo = "#4B0082"
        ivory = "#FFFFF0"
        khaki = "#F0E68C"
        lavender = "#E6E6FA"
        lavenderblush = "#FFF0F5"
        lawngreen = "#7CFC00"
        lemonchiffon = "#FFFACD"
        lightblue = "#ADD8E6"
        lightcoral = "#F08080"
        lightcyan = "#E0FFFF"
        lightgoldenrodyellow = "#FAFAD2"
        lightgreen = "#90EE90"
        lightgrey = "#D3D3D3"
        lightpink = "#FFB6C1"
        lightsalmon = "#FFA07A"
        lightseagreen = "#20B2AA"
        lightskyblue = "#87CEFA"
        lightslategray = "#778899"
        lightsteelblue = "#B0C4DE"
        lightyellow = "#FFFFE0"
        lime = "#00FF00"
        limegreen = "#32CD32"
        linen = "#FAF0E6"
        maroon = "#800000"
        mediumaquamarine = "#66CDAA"
        mediumblue = "#0000CD"
        mediumorchid = "#BA55D3"
        mediumpurple = "#9370DB"
        mediumseagreen = "#3CB371"
        mediumslateblue = "#7B68EE"
        mediumspringgreen = "#00FA9A"
        mediumturquoise = "#48D1CC"
        mediumvioletred = "#C71585"
        midnightblue = "#191970"
        mintcream = "#F5FFFA"
        mistyrose = "#FFE4E1"
        moccasin = "#FFE4B5"
        navajowhite = "#FFDEAD"
        navy = "#000080"
        oldlace = "#FDF5E6"
        olive = "#808000"
        olivedrab = "#6B8E23"
        orange = "#FFA500"
        orangered = "#FF4500"
        orchid = "#DA70D6"
        palegoldenrod = "#EEE8AA"
        palegreen = "#98FB98"
        paleturquoise = "#AFEEEE"
        palevioletred = "#DB7093"
        papayawhip = "#FFEFD5"
        peachpuff = "#FFDAB9"
        peru = "#CD853F"
        pink = "#FFC0CB"
        plum = "#DDA0DD"
        powderblue = "#B0E0E6"
        purple = "#800080"
        red = "#FF0000"
        rosybrown = "#BC8F8F"
        royalblue = "#4169E1"
        saddlebrown = "#8B4513"
        salmon = "#FA8072"
        sandybrown = "#F4A460"
        seagreen = "#2E8B57"
        seashell = "#FFF5EE"
        sienna = "#A0522D"
        silver = "#C0C0C0"
        skyblue = "#87CEEB"
        slateblue = "#6A5ACD"
        slategray = "#708090"
        snow = "#FFFAFA"
        springgreen = "#00FF7F"
        steelblue = "#4682B4"
        tan = "#D2B48C"
        teal = "#008080"
        thistle = "#D8BFD8"
        tomato = "#FF6347"
        turquoise = "#40E0D0"
        violet = "#EE82EE"
        wheat = "#F5DEB3"
        white = "#FFFFFF"
        whitesmoke = "#F5F5F5"
        yellow = "#FFFF00"
        yellowgreen = "#9ACD32"
    }

    SlackBackend([string]$Token) {
        $this.Initialize($Token)
    }

    SlackBackend([string]$Token, [hashtable]$Options) {
        $this.Initialize($Token)
        $this.Connection.Config.Options = $Options
    }

    [void]Initialize([string]$Token) {
        Import-Module PSSlack -Verbose:$false -ErrorAction Stop

        $config = [SlackConnectionConfig]::new()
        $secToken = $Token | ConvertTo-SecureString -AsPlainText -Force
        $config.Credential = New-Object System.Management.Automation.PSCredential('asdf', $secToken)
        $conn = [SlackConnection]::New()
        $conn.Config = $config
        $this.Connection = $conn
    }

    # Connect to Slack
    [void]Connect() {
        $this.Connection.Connect()
        $this.BotId = $this.GetBotIdentity()
        $this.LoadUsers()
        $this.LoadRooms()
    }

    # Receive a message from the websocket
    [Message[]]ReceiveMessage() {
        $messages = New-Object -TypeName System.Collections.ArrayList
        try {

            # Read the output stream from the receive job and get any messages since our last read
            $jsonResult = $this.Connection.ReadReceiveJob()

            if ($null -ne $jsonResult -and $jsonResult -ne [string]::Empty) {
                Write-Debug -Message "[SlackBackend:ReceiveMessage] Received `n$jsonResult"

                # Strip out Slack's URI formatting
                $jsonResult = $this._SanitizeURIs($jsonResult)

                $slackMessages = @($jsonResult | ConvertFrom-Json)
                foreach ($slackMessage in $slackMessages) {

                    # We only care about certain message types from Slack
                    if ($slackMessage.Type -in $this.MessageTypes) {
                        $msg = [Message]::new()

                        # Set the message type and optionally the subtype
                        #$msg.Type = $slackMessage.type
                        switch ($slackMessage.type) {
                            'channel_rename' {
                                $msg.Type = [MessageType]::ChannelRenamed
                            }
                            'message' {
                                $msg.Type = [MessageType]::Message
                            }
                            'pin_added' {
                                $msg.Type = [MessageType]::PinAdded
                            }
                            'pin_removed' {
                                $msg.Type = [MessageType]::PinRemoved
                            }
                            'presence_change' {
                                $msg.Type = [MessageType]::PresenceChange
                            }
                            'reaction_added' {
                                $msg.Type = [MessageType]::ReactionAdded
                            }
                            'reaction_removed' {
                                $msg.Type = [MessageType]::ReactionRemoved
                            }
                            'star_added' {
                                $msg.Type = [MessageType]::StarAdded
                            }
                            'star_removed' {
                                $msg.Type = [MessageType]::StarRemoved
                            }
                        }

                        if ($slackMessage.subtype) {
                            switch ($slackMessage.subtype) {
                                'channel_join' {
                                    $msg.Subtype = [MessageSubtype]::ChannelJoined
                                }
                                'channel_leave' {
                                    $msg.Subtype = [MessageSubtype]::ChannelLeft
                                }
                                'channel_name' {
                                    $msg.Subtype = [MessageSubtype]::ChannelRenamed
                                }
                                'channel_purpose' {
                                    $msg.Subtype = [MessageSubtype]::ChannelPurposeChanged
                                }
                                'channel_topic' {
                                    $msg.Subtype = [MessageSubtype]::ChannelTopicChanged
                                }
                            }
                        }

                        $msg.RawMessage = $slackMessage
                        if ($slackMessage.text)    { $msg.Text = $slackMessage.text }
                        if ($slackMessage.channel) { $msg.To   = $slackMessage.channel }
                        if ($slackMessage.user)    { $msg.From = $slackMessage.user }

                        if ($slackMessage.ts) {
                            $unixEpoch = [datetime]'1970-01-01'
                            $msg.Time = $unixEpoch.AddSeconds($slackMessage.ts)
                        } else {
                            $msg.Time = (Get-Date).ToUniversalTime()
                        }

                        # Sometimes the message is nested in a 'message' subproperty. This could be
                        # if the message contained a link that was unfurled.  We would receive a
                        # 'message_changed' message and need to look in the 'message' subproperty
                        # to see who the message was from.  Slack is weird
                        # https://api.slack.com/events/message/message_changed
                        if ($slackMessage.message) {
                            if ($slackMessage.message.user) {
                                $msg.From = $slackMessage.message.user
                            }
                            if ($slackMessage.message.text) {
                                $msg.Text = $slackMessage.message.text
                            }
                        }

                        # ** Important safety tip, don't cross the streams **
                        # Only return messages that didn't come from the bot
                        # else we'd cause a feedback loop with the bot processing
                        # it's own responses
                        if (-not $this.MsgFromBot($msg.From)) {
                            $messages.Add($msg) > $null
                        }
                    }
                }
            }
        } catch {
            Write-Error $_
        }

        return $messages
    }

    # Send a Slack ping
    [void]Ping() {
        # $msg = @{
        #     id = 1
        #     type = 'ping'
        #     time = [System.Math]::Truncate((Get-Date -Date (Get-Date) -UFormat %s))
        # }
        # $json = $msg | ConvertTo-Json
        # $bytes = ([System.Text.Encoding]::UTF8).GetBytes($json)
        # Write-Debug -Message '[SlackBackend:Ping]: One ping only Vasili'
        # $cts = New-Object System.Threading.CancellationTokenSource -ArgumentList 5000

        # $task = $this.Connection.WebSocket.SendAsync($bytes, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token)
        # do { Start-Sleep -Milliseconds 100 }
        # until ($task.IsCompleted)
        #$result = $this.Connection.WebSocket.SendAsync($bytes, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).GetAwaiter().GetResult()
    }

    # Send a message back to Slack
    [void]SendMessage([Response]$Response) {
        # Process any custom responses
        foreach ($customResponse in $Response.Data) {

            [string]$sendTo = $Response.To
            if ($customResponse.DM) {
                $sendTo = "@$($this.UserIdToUsername($Response.MessageFrom))"
            }

            switch -Regex ($customResponse.PSObject.TypeNames[0]) {
                '(.*?)PoshBot\.Card\.Response' {
                    $chunks = $this._ChunkString($customResponse.Text)
                    Write-Verbose "Split response into [$($chunks.Count)] chunks"
                    $x = 0
                    foreach ($chunk in $chunks) {
                        $attParams = @{
                            MarkdownFields = 'text'
                            Color = $customResponse.Color
                        }
                        $fbText = 'no data'
                        if (-not [string]::IsNullOrEmpty($chunk.Text)) {
                            Write-Verbose "response size: $($chunk.Text.Length)"
                            $fbText = $chunk.Text
                        }
                        $attParams.Fallback = $fbText
                        if ($customResponse.Title) {

                            # If we chunked up the response, only display the title on the first one
                            if ($x -eq 0) {
                                $attParams.Title = $customResponse.Title
                            }
                        }
                        if ($customResponse.ImageUrl) {
                            $attParams.ImageURL = $customResponse.ImageUrl
                        }
                        if ($customResponse.ThumbnailUrl) {
                            $attParams.ThumbURL = $customResponse.ThumbnailUrl
                        }
                        if ($customResponse.LinkUrl) {
                            $attParams.TitleLink = $customResponse.LinkUrl
                        }
                        if ($customResponse.Fields) {
                            $arr = New-Object System.Collections.ArrayList
                            foreach ($key in $customResponse.Fields.Keys) {
                                $arr.Add(
                                    @{
                                        title = $key;
                                        value = $customResponse.Fields[$key];
                                        short = $true
                                    }
                                )
                            }
                            $attParams.Fields = $arr
                        }

                        if (-not [string]::IsNullOrEmpty($chunk)) {
                            $attParams.Text = '```' + $chunk + '```'
                        } else {
                            $attParams.Text = [string]::Empty
                        }
                        $att = New-SlackMessageAttachment @attParams
                        $msg = $att | New-SlackMessage -Channel $sendTo -AsUser
                        $slackResponse = $msg | Send-SlackMessage -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -Verbose:$false
                    }
                    break
                }
                '(.*?)PoshBot\.Text\.Response' {
                    $chunks = $this._ChunkString($customResponse.Text)
                    foreach ($chunk in $chunks) {
                        if ($customResponse.AsCode) {
                            $t = '```' + $chunk + '```'
                        } else {
                            $t = $chunk
                        }
                        $slackResponse = Send-SlackMessage -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -Channel $sendTo -Text $t -Verbose:$false -AsUser
                    }
                    break
                }
                '(.*?)PoshBot\.File\.Upload' {
                    $uploadParams = @{
                        Token = $this.Connection.Config.Credential.GetNetworkCredential().Password
                        Channel = $sendTo
                        Path = $customResponse.Path
                    }
                    if (-not [string]::IsNullOrEmpty($customResponse.Title)) {
                        $uploadParams.Title = $customResponse.Title
                    } else {
                        $uploadParams.Title = Split-Path -Path $customResponse.Path -Leaf
                    }
                    Send-SlackFile @uploadParams -Verbose:$false
                    Remove-Item -LiteralPath $customResponse.Path -Force
                    break
                }
            }
        }

        if ($Response.Text.Count -gt 0) {
            foreach ($t in $Response.Text) {
                $slackResponse = Send-SlackMessage -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -Channel $Response.To -Text $t -Verbose:$false -AsUser
            }
        }
    }

    # Add a reaction to an existing chat message
    [void]AddReaction([Message]$Message, [ReactionType]$Type, [string]$Reaction) {
        if ($Message.RawMessage.ts) {
            if ($Type -eq [ReactionType]::Custom) {
                $emoji = $Reaction
            } else {
                $emoji = $this._ResolveEmoji($Type)
            }

            $body = @{
                name = $emoji
                channel = $Message.To
                timestamp = $Message.RawMessage.ts
            }
            $resp = Send-SlackApi -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -Method 'reactions.add' -Body $body -Verbose:$false
            if (-not $resp.ok) {
                Write-Error $resp
            }
        }
    }

    # Remove a reaction from an existing chat message
    [void]RemoveReaction([Message]$Message, [ReactionType]$Type, [string]$Reaction) {
        if ($Message.RawMessage.ts) {
            if ($Type -eq [ReactionType]::Custom) {
                $emoji = $Reaction
            } else {
                $emoji = $this._ResolveEmoji($Type)
            }

            $body = @{
                name = $emoji
                channel = $Message.To
                timestamp = $Message.RawMessage.ts
            }
            $resp = Send-SlackApi -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -Method 'reactions.remove' -Body $body -Verbose:$false
            if (-not $resp.ok) {
                Write-Error $resp
            }
        }
    }

    # Resolve a channel name to an Id
    [string]ResolveChannelId([string]$ChannelName) {
        if ($ChannelName -match '^#') {
            $ChannelName = $ChannelName.TrimStart('#')
        }
        $channelId = ($this.Connection.LoginData.channels | Where-Object name -eq $ChannelName).id
        if (-not $ChannelId) {
            $channelId = ($this.Connection.LoginData.channels | Where-Object id -eq $ChannelName).id
        }
        return $channelId
    }

    # Populate the list of users the Slack team
    [void]LoadUsers() {
        $allUsers = Get-Slackuser -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -Verbose:$false
        $allUsers | ForEach-Object {
            $user = [SlackPerson]::new()
            $user.Id = $_.ID
            $user.Nickname = $_.Name
            $user.FullName = $_.RealName
            $user.FirstName = $_.FirstName
            $user.LastName = $_.LastName
            $user.Email = $_.Email
            $user.Phone = $_.Phone
            $user.Skype = $_.Skype
            $user.IsBot = $_.IsBot
            $user.IsAdmin = $_.IsAdmin
            $user.IsOwner = $_.IsOwner
            $user.IsPrimaryOwner = $_.IsPrimaryOwner
            $user.IsUltraRestricted = $_.IsUltraRestricted
            $user.Status = $_.Status
            $user.TimeZoneLabel = $_.TimeZoneLabel
            $user.TimeZone = $_.TimeZone
            $user.Presence = $_.Presence
            $user.Deleted = $_.Deleted
            Write-Verbose -Message "[SlackBackend:LoadUsers] Adding user: $($_.ID):$($_.Name)"
            $this.Users[$_.ID] =  $user
        }

        foreach ($key in $this.Users.Keys) {
            if ($key -notin $allUsers.ID) {
                $this.Users.Remove($key)
            }
        }
    }

    # Populate the list of channels in the Slack team
    [void]LoadRooms() {
        $allChannels = Get-SlackChannel -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -ExcludeArchived -Verbose:$false

        $allChannels | ForEach-Object {
            $channel = [SlackChannel]::new()
            $channel.Id = $_.ID
            $channel.Name = $_.Name
            $channel.Topic = $_.Topic
            $channel.Purpose = $_.Purpose
            $channel.Created = $_.Created
            $channel.Creator = $_.Creator
            $channel.IsArchived = $_.IsArchived
            $channel.IsGeneral = $_.IsGeneral
            $channel.MemberCount = $_.MemberCount
            foreach ($member in $_.Members) {
                $channel.Members.Add($member, $null)
            }
            Write-Verbose -Message "[SlackBackend:LoadRooms] Adding channel: $($_.ID):$($_.Name)"
            $this.Rooms[$_.ID] = $channel
        }

        foreach ($key in $this.Rooms.Keys) {
            if ($key -notin $allChannels.ID) {
                $this.Rooms.Remove($key)
            }
        }
    }

    # Get the bot identity Id
    [string]GetBotIdentity() {
        return $this.Connection.LoginData.self.id
    }

    # Determine if incoming message was from the bot
    [bool]MsgFromBot([string]$From) {
        return $this.BotId -eq $From
    }

    # Get a user by their Id
    [SlackPerson]GetUser([string]$UserId) {
        $user = $this.Users[$UserId]
        if ($user) {
            return $user
        } else {
            $this.LoadUsers()
            return $this.Users[$UserId]
        }
    }

    # Get a user Id by their name
    [string]UsernameToUserId([string]$Username) {
        $Username = $Username.TrimStart('@')
        $user = (Get-SlackUser -Token $this.Connection.Config.Credential.GetNetworkCredential().Password -Name $Username -Verbose:$false -ErrorAction SilentlyContinue)
        if ($user) {
            # Reload our user cache if we don't know about this user
            if (-not $this.Users.ContainsKey($user.Id)) {
                $this.LoadUsers()
            }
            return $user.Id
        } else {
            return $null
        }
    }

    # Get a user name by their Id
    [string]UserIdToUsername([string]$UserId) {
        if ($this.Users.ContainsKey($UserId)) {
            return $this.Users[$UserId].Nickname
        } else {
            $this.LoadUsers()
            return $this.Users[$UserId].Nickname
        }
    }

    # Remove extra characters that Slack decorates urls with
    hidden [string] _SanitizeURIs([string]$Text) {
        $sanitizedText = $Text -replace '<([^\|>]+)\|([^\|>]+)>', '$2'
        $sanitizedText = $sanitizedText -replace '<(http([^>]+))>', '$1'
        return $sanitizedText
    }

    # Break apart a string by number of characters
    hidden [System.Collections.ArrayList] _ChunkString([string]$Text) {
        return [regex]::Split($Text, "(?<=\G.{$($this.MaxMessageLength)})", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }

    # Resolve a reaction type to an emoji
    hidden [string]_ResolveEmoji([ReactionType]$Type) {
        $emoji = [string]::Empty
        Switch ($Type) {
            'Success'    { return 'white_check_mark' }
            'Failure'    { return 'exclamation' }
            'Processing' { return 'gear' }
        }
        return $emoji
    }
}

function New-PoshBotSlackBackend {
    <#
    .SYNOPSIS
        Create a new instance of a Slack backend
    .DESCRIPTION
        Create a new instance of a Slack backend
    .PARAMETER Configuration
        The hashtable containing backend-specific properties on how to create the Slack backend instance.
    .EXAMPLE
        PS C:\> $backendConfig = @{Name = 'SlackBackend'; Token = '<SLACK-API-TOKEN>'}
        PS C:\> $backend = New-PoshBotSlackBackend -Configuration $backendConfig

        Create a Slack backend using the specified API token
    .INPUTS
        Hashtable
    .OUTPUTS
        SlackBackend
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function', Target='*')]
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('BackendConfiguration')]
        [hashtable[]]$Configuration
    )

    process {
        foreach ($item in $Configuration) {
            if (-not $item.Token) {
                throw 'Configuration is missing [Token] parameter'
            } else {
                Write-Verbose 'Creating new Slack backend instance'
                $backend = [SlackBackend]::new($item.Token, $item)
                if ($item.Name) {
                    $backend.Name = $item.Name
                }
                $backend
            }
        }
    }
}

Export-ModuleMember -Function 'New-PoshBotSlackBackend'
