# heroku-playwright-python-browsers
A buildpack to install Playwright browser executables for usage with Python on Heroku. 

**NOTE**: this buildpack and the following instructions was developed for usage with Chromium in mind. It is likely to work with Firefox and Webkit as well BUT hasn't been tested by the author. You are on your own when using Firefox and Webkit since I don't use those tools. Let me know if this buildpack works though and I'll update the docs.

# Usage

Follow the steps below.

## Tell Python to install `playwright`

This buildpack relies on the CLI command `playwright install`. This requires [`playwright`](https://pypi.org/project/playwright/) to be installed. Do this by specifying a `requirements.txt` or any other methods accepted by the Heroku Python buildpacks.

Example `requirements.txt`:
```
environs==10.3.0
exceptiongroup==1.2.0
greenlet==3.0.1
gunicorn==21.2.0
idna==3.6
iniconfig==2.0.0
marshmallow==3.20.2
packaging==23.2
playwright==1.40.0
pluggy==1.3.0
```

## Buildpack ordering

Order matters for this buildpack to work. Here's the run order that you should should have:

![Buildpack Image](Buildpacks.PNG)

1. The official [Python buildpack](https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-python).
    - Runs first so that Playwright is available as a CLI tool after the package installation is done
2. This build pack. [Here's how to add this buildpack to your app](https://devcenter.heroku.com/articles/buildpacks#using-a-third-party-buildpack) by using its Git URL.
3. The [heroku-playwright-buildpack](https://github.com/playwright-community/heroku-playwright-buildpack)


## Customize the following config variables:
1. `PLAYWRIGHT_BUILDPACK_BROWSERS` accepts a comma-separated list of the browser names. By default, it's installing executables for `chromium,firefox,webkit`.
    - E.g. To only install Chromium dependencies, set the variable to `chromium`. This will reduce the slug size in the end too. 
        - **NOTE**: this is what the author uses, usage with the other 2 browsers are unknown. Feel free to test them out and let me know if they work and I'll update the docs.
    - This config variable is intended to be shared with another variable with the same name from [heroku-playwright-buildpack](https://github.com/playwright-community/heroku-playwright-buildpack).
2. `BUILDPACK_BROWSERS_INSTALL_PATH` is the path where the browsers will be installed. Its default value is `browsers` and it's a relative path starting from the [`BUILD_DIR`](https://devcenter.heroku.com/articles/buildpack-api#bin-compile) (the starting directory of the compiled slug to be used by Heroku). It's necessary to have the installed browsers within the `BUILD_DIR` to have the file included by the time Heroku starts the dyno.
    - E.g. To install in the directory `utils/browsers`, set the variable to `utils/browsers`.

## Modify your browser creation script

Since the browsers are installed in a non-default location, we have to specify the executable path when we create the browser instances. The following config variables are exported by the buildpack IF the appropriate browsers are installed:
- `CHROMIUM_EXECUTABLE_PATH` 
- `FIREFOX_EXECUTABLE_PATH`
- `WEBKIT_EXECUTABLE_PATH`

For example, if you use `PLAYWRIGHT_BUILDPACK_BROWSERS=chromium`, the script will only install the executable for Chromium and only `CHROMIUM_EXECUTABLE_PATH` will be set. 

Here's how you should create your browser using the config variable above:

```
with sync_playwright() as p:
  try:
      # for chromium, you don't have to pass in flags like `no-sandbox` or `headless` because they are enabled by default.
      # Flags like `--disable-dev-shm-usage` and `--remote-debugging-port=9222` can be added if needed but I haven't needed that
      browser = p.chromium.launch(executable_path=os.getenv("CHROMIUM_EXECUTABLE_PATH"), ...other arguments)
```


# Questions

**1. Why doesn't this buildpack install the requirements as well?**

The command to install the system packages along with the browser is `playwright install --with-deps`. For some reason, this action is blocked by Heroku since it uses sudo underneath (which is not allowed as of 2024). Thus, only the browser installation can go through but that alone is not enough. We still need the system packages which is provided by `heroku-playwright-buildpack`.

**2. The script doesn't work for me. What do I do?**

Here are a few things to consider:
- This buildpack is meant for Python Playwright and was developed with Chromium in mind. Any other browser/Playwright distro is not tested by me so I offer no guarantees there
- Verify that the installation is successful. Look at the build logs, you should see progress bar for the executable installations
    - Verify that the executable paths are properly set. Look through the logs (the app's log, not the buildpack) for something like this
    ```
    2024-02-07T21:57:03.415283+00:00 app[release.8706]: ----> CHROMIUM_EXECUTABLE_PATH is /app/browsers/chromium-1091/chrome-linux/chrome
    2024-02-07T21:57:03.555317+00:00 app[release.8706]: ----> FIREFOX_EXECUTABLE_PATH is /app/browsers/firefox-1429/firefox/firefox
    2024-02-07T21:57:03.690086+00:00 app[release.8706]: ----> WEBKIT_EXECUTABLE_PATH is /app/browsers/webkit-1944/pw_run.sh
    ```
    - You can also `heroku run bash` into the dyno and search for the installation folder to:
        - Verify that the exe are downloaded by going into `BUILDPACK_BROWSERS_INSTALL_PATH`
        - Verify that the env variables like `CHROMIUM_EXECUTABLE_PATH` are set properly

# Credits
A lot of code and patterns were taken from [heroku-playwright-buildpack](https://github.com/playwright-community/heroku-playwright-buildpack).

Idea for the buildpack was inspired by [playwright-python-heroku-buildpack](https://github.com/binoche9/playwright-python-heroku-buildpack).

