# Sakae Shalom Church DVD-Video Scripts

## 特徴

このスクリプトは、祈祷会と日曜礼拝用のDVDビデオを作成し、DVD-Rメディアに自動的に書き込みます。
手作業では、空のDVD-Rをドライブに挿入するだけです。

このスクリプトでは、以下の機能が実装されています。
- 祈祷会（金曜日の夕方）と日曜日の礼拝ごとに以下の操作を行います。
 - ワークスペースを作成します
 - OBS Studioによって記録されたflvファイルをDVDビデオ用のmpegファイルに変換します。
 - 音圧を-23LUFSあたりに調整します
- 上記に加えて、毎週日曜日に、以下の操作を行います。
  - 金曜日の祈祷会と日曜日の礼拝を含むISOイメージファイルを作成します。
  - DVD-Rへデータを書き込みます。
  - DVDへの書き込みが完了したら、メールまたはDiscordチャネルで通知します。 

## 必要な環境など

- OS: CentOS 8
- ソフトウェア
  - [FFmpeg](https://ffmpeg.org/)
  - [dvdauthor](http://dvdauthor.sourceforge.net/)
  - mkisofs ([genisoimage](http://cdrkit.org/) に含まれるコマンド)
  - dvdrecord ([wodim](http://cdrkit.org/) に含まれるコマンド)
- ハードコードされた事項 (適宜、使用者で調整してください。)
  - ビデオファイルは `~/Videos/` の下に生成され、形式は `obs-%Y%m%d-%H%M.flv` である必要があります。
  - 祈祷会は19:30に始まり、日曜日の礼拝は10:25に始まります。
  - 日曜礼拝と祈祷会でそれぞれ、最初の15秒と45秒を削除します。
  - このリポジトリの場所 (`~/dvd`)。
  - 外部スクリプト (メール・discordメッセージ送信用)。不要な場合、 `script/burn-email.sh` の中身を消してください。

## セットアップ

1. 空のディレクトリ `~/dvd` を作成します。
2. このリポジトリを `~/dvd/%Y%m%d` に複製します。`%Y%m%d` は年月日を表す8桁の数字です。
3. リポジトリ内の `script` ディレクトリへのシンボリックリンクを作成します。
   ```
   cd ~/dvd
   ln -s script $(date +%Y%m%d)/script
   ```
4. Crontabは次のように設定する必要があります。
   ```
   45 23 * * 5 ./dvd/script/cron-friday.sh
   15 12 * * 0 ./dvd/script/cron-sunday.sh
   ```
5. オプション: 書き込みが完了し新しいディスクを待っているときに電子メールが必要な場合は、 `~/.config/burn-dvd.rc` に送付先などを設定します。
