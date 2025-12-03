import consumer from "channels/consumer"

document.addEventListener("turbo:load", () => {
    document.querySelectorAll("[data-message-id]").forEach((element) => {
        const messageId = element.dataset.messageId

        consumer.subscriptions.create(
            { channel: "RepliesChannel", message_id: messageId },
            {
                received(data) {
                    document
                        .getElementById(`message_${messageId}_replies`)
                        ?.insertAdjacentHTML("beforeend", data)
                }
            }
        )
    })
})