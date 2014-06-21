# Committal
_a small app to keep a GitHub repo in sync with Dropbox (poorly)_

Committal keeps _one_ GitHub Repo in sync with _one_ Dropbox repo, using webhooks and silly assumptions. At this time Committal assumes changes will only happen at one place at once and doesn't merge conflicts– [it just picks a winner](http://31.media.tumblr.com/tumblr_m987u4j60w1ryzkcmo1_500.gif).

## Setup
To setup Committal for yourself take the following steps:

### Create a Dropbox App
To setup Committal, you must first get a Dropbox access token. You may get this by creating a Dropbox App, through [Dropbox's Dev Center](https://www.dropbox.com/developers). In creating your app, select that you want access to all files and folders _of all types_ within a user's Dropbox. This will get you API keys, however to get an access token, you'll need to go through an OAuth flow, at time of writing, Dropbox has a button in app settings to get a personal access token– _get that_.

### Clone the repo to your computer

```sh
git clone https://github.com/nquinlan/committal.git committal
```

### Switch into the new directory

```sh
cd committal
```

### Initialize and push to Heroku
This requires the [Heroku Toolbelt](https://toolbelt.heroku.com/). _Committal may be installed elsewhere, however for simplicity's sake the steps are described for Heroku._

```sh
heroku init
git push heroku master
```

### Setup the required environment variables

```sh
heroku config:set TMP_LOC=/tmp/ GIT_REPO_URL=https://github.com/nquinlan/committal.git GIT_USER_NAME=robot GIT_USER_PASSWORD=password GIT_USER_EMAIL=committal@example.com DROPBOX_ACCESS_TOKEN=abCDEfGhiJklmn_OpQrSTuVWYz DROPBOX_FOLDER=/Documents/todo
```

| Environment Variable | Description |
|:---------------------------:|:-----------------|
| `TMP_LOC` | The location of your temporary folder. For Heroku, it should be `/tmp/` or a child within `/tmp/`. |
| `GIT_REPO_URL` | The repo that you want to keep in sync. |
| `GIT_USER_NAME` | The name of the user who will be committing changes. |
| `GIT_USER_PASSWORD` | The password of the user who will be committing changes. (Protip: Github allows you to setup user tokens for this) |
| `GIT_USER_EMAIL` | The email of the user who will be committing changes. |
| `DROPBOX_ACCESS_TOKEN` | The access token for the user who owns the Dropbox file you want to maintain.  |
| `DROPBOX_FOLDER` | The folder within the Dropbox you want to keep in sync. |

### Setup Your Repo's Webhook
In the Settings of the repo you wish to sync on Github, configure a custom webhook, to post to `https://your-app-name.herokuapp.com/hook/github`.


### Setup Your Dropbox App's Webhook
In the App Settings of your Dropbox Application, configure a webhook, to post to `https://your-app-name.herokuapp.com/hook/dropbox`.


**Congrats, you're good to go!**

## Todo
There are a number of things I want this app to do in the future. _It was built rather quickly._

- Higher quality sync (merge, rather than just picking a winner)
- Deal with whitespace better
- Authenticate requests from webhooks
- Deep download (right now this app will only download and sync first level files and will not descend recursively into folders to download all files, in the future this should be changes)
- Multiple repo/file sync

## License

MIT - © 2014 Nick Quinlan
