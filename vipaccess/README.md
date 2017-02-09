## How it works

* Generate a new VIP Credential ID and corresponding TOTP secret
* Register the Credential ID with your organization
* Register the TOTP secret with Google Authenticator (or your favourite OTP client)
* Generate OTP from your client

## Setup

```
sudo pip install python-vipaccess
sudo brew install oath-toolkit
```

## Use

* Generate a new VIP Credential ID
```
→ vipaccess » python generate.py
otpauth://totp/VIP%20Access:VSMT<RANDOM>?secret=<SECRET>&issuer=Symantec
BE AWARE that this new credential expires on this date: <ISO date>
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

## Have fun

Now generate your OTPs without the proprietary Symantec software

## Credits

[Cyrozap](https://www.cyrozap.com/2014/09/29/reversing-the-symantec-vip-access-provisioning-protocol/) for reversing the protocol and writing a [free client](https://github.com/cyrozap/python-vipaccess) that I just copied to `generate.py` (with a 2 char change) in this directory.
