# Sakae Shalom Church DVD-Video Scripts

## Features

This scripts create DVD-Video for the prayer meeting and Sunday service and automatically burn into DVD-R media.
Manual work is only inserting empty DVD-Rs into a drive.

In this script, these features are implemented.
- For each prayer meeting (at Friday evening) and Sunday service.
  - Create workspace
  - Convert a flv file recorded by OBS Studio to a MPG file for DVD-Video.
  - Adjust audio loudness
- For each Sunday
  - Make an ISO image file including Friday prayer meeting and Sunday service.
  - Burn DVD(s)
  - Notify on a Discord channel when the DVD is available.

## Prerequisition

- OS: CentOS 8
- Hardcoded items
  - Video files should be generated under `~/Videos/` and the format should be `obs-%Y%m%d-%H%M.flv`.
  - Prayer meeting starts at 19:30, Sunday service starts at 10:25.
  - First 15 seconds and 45 seconds are removed for Sunday service and Prayer meeting, respectively.
  - Location of this repository.
  - External scripts to send email, send message to discord. If you don't need, make `script/burn-email.sh` empty.

## Setup

1. Create empty directory `~/dvd`.
2. Clone this repository to `~/dvd/%Y%m%d`, where `%Y%m%d` represents year-month-day.
3. Create a symbolic link `script` that points to this `script` directory in the repository.
   ```
   cd ~/dvd
   ln -s script $(date +%Y%m%d)/script
   ```
4. Crontab should be configured as below.
   ```
   45 23 * * 5 ./dvd/script/cron-friday.sh
   15 12 * * 0 ./dvd/script/cron-sunday.sh
   ```
5. Optionally, create `~/.config/burn-dvd.rc` if you need email when waiting a new disc.
