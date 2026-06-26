# Chat Flow

## Creation
- booking proposal creates one chat
- `AssetController._createMessage()` writes:
  - `chats/{chatId}`
  - first message in `chats/{chatId}/messages`
  - mirrored chat summaries for owner and renter

## Message sending
- `ChatController.sendMessage()`
- `LNDMessagingService.sendMessage()`
- appends a shared message and updates both mirrored chat summaries

## Inbox view
- `MessagesController` listens to `userChats/{uid}/chats`
- ordering comes from `lastMessageDate`
- unread state is per-user through `hasRead`

## Conversation view
- `ChatListController` listens to `chats/{chatId}/messages`
- opening a chat marks the current user's mirrored chat doc as read

## Booking coupling
- chat footer derives actions from booking subscription in `ChatController`
- accept action uses booking callable flow
- handover and return actions depend on booking tokens and booking nested flags

## Archive behavior
- archived chats are filtered by mirrored chat `status`
- review submission archives renter chat summary
- declined overlapping bookings can archive losing renter chat summaries
