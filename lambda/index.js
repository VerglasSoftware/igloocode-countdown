exports.handler = async () => {
  const channelId = process.env.CHANNEL_ID;
  const botToken = process.env.BOT_TOKEN;
  const daysLeft = getDaysLeft();

  const response = await fetch(`https://discord.com/api/v10/channels/${channelId}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bot ${botToken}`,
      'Content-Type': 'application/json',
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      name: `⏳ days until igloocode: ${daysLeft}`,
    }),
  });

  const body = await response.json();

  return {
    statusCode: response.status,
    body: JSON.stringify(body),
  };
};

function getDaysLeft() {
  const target = new Date('2026-03-23');
  const today = new Date();
  return Math.max(0, Math.ceil((target - today) / (1000 * 60 * 60 * 24)));
}
