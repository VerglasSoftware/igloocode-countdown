const https = require('https');

exports.handler = async () => {
  const channelId = process.env.CHANNEL_ID;
  const botToken = process.env.BOT_TOKEN;
  const daysLeft = getDaysLeft();

  const data = JSON.stringify({
    name: `⏳ days until igloocode: ${daysLeft}`
  });

  const options = {
    hostname: 'discord.com',
    path: `/api/v10/channels/${channelId}`,
    method: 'PATCH',
    headers: {
      'Authorization': `Bot ${botToken}`,
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, res => {
      res.on('data', d => process.stdout.write(d));
      res.on('end', resolve);
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
};

function getDaysLeft() {
  const target = new Date('2026-03-23');
  const today = new Date();
  return Math.max(0, Math.ceil((target - today) / (1000 * 60 * 60 * 24)));
}
