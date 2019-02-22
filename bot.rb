# frozen_string_literal: true

require 'discordrb'

TOKEN = 'HOGEHOGE'
TTS_CHANNELS = ['#General'].freeze
MP3_DIR      = '/data/se'

bot = Discordrb::Commands::CommandBot.new token: TOKEN, prefix: '!'

hash = {}

bot.message(content: 'りるるん') do |event|
  event.respond 'るんるんりるるん☆'
end

bot.message(start_with: '使い方') do |event|
  event << '```
単語に反応していろいろやるbot！
コマンド一覧:〇〇募集 〇〇参加 〇〇終了 一覧
!connect !destroy !list !se 〇〇
  ```'
end

bot.message(end_with: '募集') do |event|
  msgs = event.content.split('募集')[0]
  unless hash.key?(msgs)
    event.send_message("【#{msg}】はすでに募集中です！")
    hash.each do |h|
      event << "```【#{h[0]}】 参加者: #{h[1].join(', ')}```"
    end
    return nil
  end
  msg = msgs
  user = event.user
  name = user.nickname.nil? ? user.username : user.nickname

  event.send_message("#{name}さんが【#{msg}】を募集するよ")
  hash[msg] = [name]
end

bot.message(end_with: '参加') do |event|
  msg = event.content.split('参加')[0]
  user = event.user
  name = user.nickname.nil? ? user.username : user.nickname

  unless hash.key?(msg)
    event.send_message("【#{msg}】はまだ募集してないよ")
    next
  end

  event.send_message("#{name}さんが【#{msg}】に参加するよ")
  hash[msg] << name
end

bot.message(end_with: '終了') do |event|
  msg = event.content.split('終了')[0]

  unless hash.key?(msg)
    event.send_message("【#{msg}】はまだ募集してないよ")
    next
  end

  hash.delete(msg)
  event.send_message("【#{msg}】募集を終了するよ☆")
end

bot.message(start_with: '一覧') do |event|
  event.send_message('まだ募集してないよ！') if hash.empty?
  hash.each do |h|
    event << "```【#{h[0]}】 参加者: #{h[1].join(', ')}```"
  end
end

bot.command(:connect, description: 'Join Bot', usage: '!connect') do |event|
  channel = event.user.voice_channel

  unless channel
    event << '```ボイスチャンネルに接続されていません```'
    next
  end

  bot.voice_connect(channel)
  event << "```【#{channel.name}】に接続しました。```"
end

bot.command(:destroy, description: 'Destroy bot', usage: '!destroy') do |event|
  channel = event.user.voice_channel
  server = event.server.resolve_id

  unless channel
    event << '```ボイスチャンネルに接続されていません```'
    next
  end

  bot.voice_destroy(server)
  event << "```「#{channel.name}から切断されました。」```"
end

bot.command(:se, description: 'Play SE', usage: '!se NAME') do |event, name|
  voice_bot = event.voice
  se = "#{MP3_DIR}/#{name}.mp3"
  option = '-b:a 256k -af volume=-8dB'
  voice_bot&.play_file(se, option) if File.exist?(se)
  nil
end

bot.command(:list, description: 'List SE', usage: '!list') do |event|
  list = Pathname.glob("#{MP3_DIR}/*").map(&:basename)
  event << "```#{list}```"
end

bot.run
