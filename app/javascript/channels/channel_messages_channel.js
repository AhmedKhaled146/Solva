import consumer from "channels/consumer"

document.addEventListener("turbo:load", () => {
    const messagesContainer = document.getElementById("messages")
    const channelElement = document.getElementById("channel-show")

    if (!messagesContainer || !channelElement) return

    const channelId = channelElement.dataset.channelId

    console.log("[ChannelMessagesChannel] subscribing to channel", channelId)

    consumer.subscriptions.create(
        { channel: "ChannelMessagesChannel", channel_id: channelId },
        {
            connected() {
                console.log("[ChannelMessagesChannel] Connected")
            },

            disconnected() {
                console.log("[ChannelMessagesChannel] Disconnected")
            },

            received(data) {
                console.log("[ChannelMessagesChannel] Received:", data)
                messagesContainer.insertAdjacentHTML("beforeend", data)
                messagesContainer.scrollTop = messagesContainer.scrollHeight
            }
        }
    )
})