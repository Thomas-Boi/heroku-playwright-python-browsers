# heroku-playwright-chromium
A buildpack to install the Playwright Chromium executable ONLY. 


# Usage

1. Add this buildpack to your app alongside the [heroku-playwright-buildpack](https://github.com/playwright-community/heroku-playwright-buildpack).
  - The script CANNOT install the system requirements due to restrictions from Heroku. It's only able to install the Chromium exe. 
  - Thus, we rely on [heroku-playwright-buildpack](https://github.com/playwright-community/heroku-playwright-buildpack) to get the other packages.
2. Run and deploy

# Customization
By default, this will install the necessary exe into a folder called `/browsers` under the build directory (the directory where the root script lives).

To change the this folder's name, override the `INSTALL_PATH` environmental variable.

# Notes
This was developed for usage with `playwright-python` in mind so support for other languages is unknown.



