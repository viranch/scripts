## Credits

[Cyrozap](https://www.cyrozap.com/2014/09/29/reversing-the-symantec-vip-access-provisioning-protocol/) for reversing the protocol and writing a [free client](https://github.com/cyrozap/python-vipaccess) that I shamelessly copied to `generate.py` (with 1 line change) in this directory.

## How it works

* Generate a new VIP Credential ID and corresponding TOTP secret
* Register the Credential ID with your organization
* Register the TOTP secret with Google Authenticator (or your favourite OTP client)
* Generate OTP from your client

## Setup

```
virtualenv vip
source ./vip/bin/activate
pip install python-vipaccess

sudo brew install oath-toolkit
```

## Use

* Generate a new VIP Credential ID
```
→ vipaccess » source ./vip/bin/activate
→ vipaccess » python generate.py
otpauth://totp/VIP%20Access:VSMT<RANDOM>?secret=<SECRET>&issuer=Symantec
BE AWARE that this new credential expires on this date: <ISO date>
→ vipaccess » deactivate
→ vipaccess »
```

* Register the `VSMT<RANDOM>` part as new credential ID with your organization
* Save `<SECRET>` as your TOTP secret
* Generate OTP (using my favourite CLI OTP client)
```
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
