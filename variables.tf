variable "discord_channel_id" {
  description = "The ID of the Discord channel to rename"
  type        = string
}

variable "discord_bot_token" {
  description = "The bot token for authenticating with Discord"
  type        = string
  sensitive   = true
}