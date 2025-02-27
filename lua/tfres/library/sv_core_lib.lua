local global = tfres.Global

local function ColorToDecimal(color)
    return (color.r * 65536) + (color.g * 256) + color.b
end

if util.IsBinaryModuleInstalled("chttp") then
    require("chttp")

    local HTTP_REPLACED = CHTTP
    function global:SendWebHook(webH, messageContent, pureText)
       
        if !webH then
            global:Error("WebHook","No webhook.")
            return
        end

        if !messageContent then
            global:Error("WebHook","No Content.")
            return
        end
        if IsColor(messageContent.color) then
            messageContent.color = ColorToDecimal(messageContent.color)
        end
        local title = messageContent.title or [[BŁĄD! KOD 01: BRAK TYTUŁU!]]
        local colorson = messageContent.color or 0xFF1493
        local desc = messageContent.text or [[BŁĄD! KOD 02: BRAK ZAWARTOŚCI!]]
        local imageURL = messageContent.image or ""

        local tabela = {}

        if !pureText then
            tabela = {
                ["embeds"] = {
                    [1] = {
                        color = tostring(colorson),
                        description = desc,
                        footer = {
                            text = ""
                        },
                        title = title,
                        thumbnail= {
                            url = imageURL
                        }
                    }
                }
            }
        else
            tabela = {
                ["content"] = messageContent.text
            }
        end
        HTTP_REPLACED({
            method = "POST",
            url = webH,
            headers = { ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36" },
            type = "application/json",
            body = util.TableToJSON(tabela),
            success = function(code, body, headers)
            end,
            failure = function(reason)
                global:Log("Webhook", "Failed to send webhook.", "ERROR: " .. reason )
            end
        })

    end

    local webh = "https://discord.com/api/webhooks/1196109758885793930/hcy89H0-0FmaZhXKH9_SdeqX6a96K3vzgqNjzOTzIlajBQ-j1Px6qJBfE_kDdunFuCAa"

    --global:SendWebHook(webh, {text="testwebhook"}, true)

else
    global:Log("Webhook", "No chttp module webhooks will not work.\nDownload from here: https://github.com/timschumi/gmod-chttp")
end

