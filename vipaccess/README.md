## Credits

[Cyrozap](https://www.cyrozap.com/2014/09/29/reversing-the-symantec-vip-access-provisioning-protocol/) for reversing the protocol and writing a [free client](https://github.com/cyrozap/python-vipaccess) that I shamelessly copied to `generate.py` (with 1 line change) in this directory.

## How it works

* Generate a new VIP Credential ID and corresponding TOTP secret
* Register the Credential ID with your organization
* Register the TOTP secret with Google Authenticator (or your favourite OTP client)
* Generate OTP from your client

## Setup

Using docker:
```bash
docker pull viranch/vipaccess
```

OR Building docker image:
```bash
git clone git://github.com/viranch/scripts.git
cd scripts/vipaccess
docker build -t viranch/vipaccess .
```

OR Without docker:
```bash
git clone git://github.com/viranch/scripts.git
cd scripts/vipaccess
virtualenv vip
source ./vip/bin/activate
pip install python-vipaccess
deactivate
```

## Use

* Generate a new VIP Credential ID
```
→ ~ » docker run --rm -it viranch/vipaccess  # without docker: source ./vip/bin/activate && python generate.py && deactivate
otpauth://totp/VIP%20Access:VSMT<RANDOM>?secret=<SECRET>&issuer=Symantec
BE AWARE that this new credential expires on this date: <ISO date>
→ ~ »
```

* Register the `VSMT<RANDOM>` part as new credential ID with your organization
* Save `<SECRET>` as your TOTP secret
* Generate OTP (using my favourite CLI OTP client)
```
→ ~ » sudo brew install oath-toolkit
→ ~ » oathtool --totp -b <SECRET>
927899
→ ~ »
```

* (Optional) Clean up
```
→ vipaccess » rm -rf ./vip
```

## Have fun

Now generate your OTPs without the proprietary Symantec software

## Pro tip

* Install and run [FastScripts](https://red-sweater.com/fastscripts/)
* Put the following in `~/Library/Scripts/vip.sh`, replacing `$SECRET` with your OTP secret
```bash
#!/bin/bash
otp=$(oathtool --totp -b $SECRET)
osascript -e 'tell application "System Events"' -e 'delay 0.1' -e 'keystroke "'$otp'"' -e 'end tell' &
```
* `chmod a+x ~/Library/Scripts/vip.sh`
* Set a keyboard shortcut in FastScripts for this script
* Whenever prompted for OTP, use the shortcut and the OTP will be typed
